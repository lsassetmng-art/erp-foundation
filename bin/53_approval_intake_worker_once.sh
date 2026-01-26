#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
DO $$
DECLARE
  p record;
  cfg record;
  v_risk numeric;
  v_dry jsonb;
  v_dry_status text;
  v_title text;
  v_sql text;
  v_approval_id bigint;
  v_should_auto boolean := false;
BEGIN
  -- config (latest)
  SELECT * INTO cfg
  FROM governance.autonomy_config
  ORDER BY updated_at DESC
  LIMIT 1;

  -- pick 1 reviewed proposal not yet converted to approval
  SELECT
    pcq.policy_change_id,
    pcq.policy_key,
    pcq.proposed_action,
    pcq.proposed_value,
    pcq.confidence
  INTO p
  FROM governance.policy_change_queue pcq
  WHERE pcq.status = 'reviewed'
    AND NOT EXISTS (
      SELECT 1 FROM governance.policy_approval_queue aq
      WHERE aq.policy_change_id = pcq.policy_change_id
    )
  ORDER BY pcq.policy_change_id
  FOR UPDATE SKIP LOCKED
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  -- build title/sql_text (proposal -> SQL)
  -- NOTE: ここは「提案を実SQLに変換」する箇所
  -- 最小実装: 提案値(jsonb)に sql_text が入っていればそれを使う。無ければ pending のまま（人が後で差し込む）。
  v_title := format('[proposal] %s / %s', p.policy_key, p.proposed_action);

  IF (p.proposed_value ? 'sql_text') THEN
    v_sql := (p.proposed_value->>'sql_text');
  ELSE
    v_sql := '';
  END IF;

  v_risk := governance.risk_score(v_sql);

  IF v_sql <> '' THEN
    v_dry := governance.try_dryrun_explain(v_sql);
    v_dry_status := coalesce(v_dry->>'status','failed');
  ELSE
    v_dry := jsonb_build_object('status','skipped','reason','no_sql_text_in_proposed_value');
    v_dry_status := 'skipped';
  END IF;

  INSERT INTO governance.policy_approval_queue(
    policy_change_id, title, sql_text,
    confidence, risk_score,
    dryrun_status, dryrun_plan_json, dryrun_error
  )
  VALUES(
    p.policy_change_id, v_title, v_sql,
    p.confidence, v_risk,
    v_dry_status,
    CASE WHEN v_dry_status='ok' THEN (v_dry->'plan') ELSE NULL END,
    CASE WHEN v_dry_status='failed' THEN (v_dry->>'error') ELSE NULL END
  )
  RETURNING approval_id INTO v_approval_id;

  INSERT INTO governance.governance_action_log(action_type, ref_type, ref_id, payload)
  VALUES('approval_created','approval',v_approval_id,
         jsonb_build_object('policy_change_id',p.policy_change_id,'confidence',p.confidence,'risk',v_risk,'dryrun',v_dry));

  -- decide auto?
  IF cfg.autonomy_mode = 'auto'
     AND cfg.auto_enqueue_apply IS TRUE
     AND coalesce(p.confidence,0) >= cfg.min_confidence
     AND coalesce(v_risk,1) <= cfg.max_risk_score
  THEN
    IF cfg.require_dryrun_ok THEN
      v_should_auto := (v_dry_status = 'ok');
    ELSE
      v_should_auto := (v_dry_status IN ('ok','skipped'));
    END IF;
  END IF;

  IF v_should_auto AND v_sql <> '' THEN
    UPDATE governance.policy_approval_queue
      SET status='approved', decided_at=now(), decided_by='auto', decision_note='auto-approved by autonomy_config'
    WHERE approval_id=v_approval_id;

    INSERT INTO governance.policy_learning_event(policy_change_id, approval_id, confidence, risk_score, outcome, note)
    VALUES(p.policy_change_id, v_approval_id, p.confidence, v_risk, 'approved', 'auto');

    INSERT INTO governance.governance_action_log(action_type, ref_type, ref_id, payload)
    VALUES('approved','approval',v_approval_id, jsonb_build_object('by','auto'));
  END IF;

END $$;
SQL
