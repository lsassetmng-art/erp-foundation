#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

HOLDER="pm_loop"
LOCK_KEY="policy_apply"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
DO $$
DECLARE
  r record;
  v_locked boolean;
  v_frozen boolean;
  v_exec_id uuid;
BEGIN
  -- freeze check
  SELECT governance.is_frozen() INTO v_frozen;
  IF v_frozen THEN
    -- do nothing when frozen
    RETURN;
  END IF;

  -- acquire lock (avoid multi-run concurrency)
  SELECT governance.try_acquire_lock('policy_apply', 'pm_loop', 60) INTO v_locked;
  IF NOT v_locked THEN
    RETURN;
  END IF;

  -- pick one pending apply
  SELECT
    apply_id,
    source_policy_change_id,
    title,
    sql_text
  INTO r
  FROM governance.policy_apply_queue
  WHERE status='pending'
  ORDER BY requested_at
  FOR UPDATE SKIP LOCKED
  LIMIT 1;

  IF NOT FOUND THEN
    PERFORM governance.release_lock('policy_apply','pm_loop');
    RETURN;
  END IF;

  -- execution log (Phase14)
  INSERT INTO governance.policy_execution_log(apply_id, source_change_id, title, sql_text, executor, executor_type, autonomy_mode, status)
  VALUES (r.apply_id, r.source_policy_change_id, r.title, r.sql_text, current_user, 'service',
          (SELECT autonomy_mode FROM governance.autonomy_config ORDER BY updated_at DESC LIMIT 1),
          'started')
  RETURNING exec_id INTO v_exec_id;

  BEGIN
    -- (Phase15 placeholder) record dryrun as skipped unless you later implement real simulation
    INSERT INTO governance.policy_dryrun_result(apply_id, status, notes)
    VALUES (r.apply_id, 'skipped', 'phase15: lightweight mode (no simulation yet)');

    -- REAL EXECUTE (only place)
    EXECUTE r.sql_text;

    UPDATE governance.policy_apply_queue
       SET status='applied', applied_at=now(), last_error=NULL
     WHERE apply_id=r.apply_id;

    UPDATE governance.policy_execution_log
       SET status='applied', finished_at=now(), last_error=NULL, dryrun_status='skipped'
     WHERE exec_id=v_exec_id;

    INSERT INTO governance.ops_event(severity, event_type, message, detail)
    VALUES ('info','policy_applied','policy applied',
            jsonb_build_object('apply_id', r.apply_id, 'title', r.title));

  EXCEPTION WHEN OTHERS THEN
    UPDATE governance.policy_apply_queue
       SET status='rejected', applied_at=now(), last_error=SQLERRM
     WHERE apply_id=r.apply_id;

    UPDATE governance.policy_execution_log
       SET status='rejected', finished_at=now(), last_error=SQLERRM, dryrun_status=coalesce(dryrun_status,'skipped')
     WHERE exec_id=v_exec_id;

    INSERT INTO governance.ops_event(severity, event_type, message, detail)
    VALUES ('error','policy_apply_failed','policy apply failed',
            jsonb_build_object('apply_id', r.apply_id, 'title', r.title, 'error', SQLERRM));

    PERFORM governance.release_lock('policy_apply','pm_loop');
    RAISE;
  END;

  PERFORM governance.release_lock('policy_apply','pm_loop');
END $$;
SQL
