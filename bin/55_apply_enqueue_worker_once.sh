#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
DO $$
DECLARE
  a record;
  new_apply_id bigint;
BEGIN
  SELECT approval_id, policy_change_id, title, sql_text
  INTO a
  FROM governance.policy_approval_queue
  WHERE status='approved'
    AND coalesce(sql_text,'') <> ''
  ORDER BY created_at
  FOR UPDATE SKIP LOCKED
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  INSERT INTO governance.policy_apply_queue(
    requested_at, requested_by,
    source_policy_change_id,
    title, sql_text,
    status, applied_at, last_error
  )
  VALUES(
    now(), current_user,
    a.policy_change_id,
    a.title, a.sql_text,
    'pending', NULL, NULL
  )
  RETURNING apply_id INTO new_apply_id;

  UPDATE governance.policy_approval_queue
    SET status='enqueued', applied_apply_id=new_apply_id
  WHERE approval_id=a.approval_id;

  INSERT INTO governance.governance_action_log(action_type,ref_type,ref_id,payload)
  VALUES('apply_enqueued','apply',new_apply_id,
         jsonb_build_object('approval_id',a.approval_id,'policy_change_id',a.policy_change_id));

END $$;
SQL
