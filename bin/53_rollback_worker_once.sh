#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
DO $$
DECLARE
  r record;
  v_exec_id uuid;
BEGIN
  SELECT rollback_id, title, rollback_sql
  INTO r
  FROM governance.rollback_plan
  WHERE status='ready'
  ORDER BY created_at
  FOR UPDATE SKIP LOCKED
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  INSERT INTO governance.rollback_execution_log(rollback_id, status)
  VALUES (r.rollback_id, 'started')
  RETURNING exec_id INTO v_exec_id;

  BEGIN
    EXECUTE r.rollback_sql;

    UPDATE governance.rollback_plan
       SET status='executed'
     WHERE rollback_id=r.rollback_id;

    UPDATE governance.rollback_execution_log
       SET status='executed', finished_at=now(), last_error=NULL
     WHERE exec_id=v_exec_id;

    INSERT INTO governance.ops_event(severity, event_type, message, detail)
    VALUES ('warn','rollback_executed','rollback executed',
            jsonb_build_object('rollback_id', r.rollback_id, 'title', r.title));

  EXCEPTION WHEN OTHERS THEN
    UPDATE governance.rollback_plan
       SET status='failed'
     WHERE rollback_id=r.rollback_id;

    UPDATE governance.rollback_execution_log
       SET status='failed', finished_at=now(), last_error=SQLERRM
     WHERE exec_id=v_exec_id;

    INSERT INTO governance.ops_event(severity, event_type, message, detail)
    VALUES ('error','rollback_failed','rollback failed',
            jsonb_build_object('rollback_id', r.rollback_id, 'title', r.title, 'error', SQLERRM));

    RAISE;
  END;
END $$;
SQL
