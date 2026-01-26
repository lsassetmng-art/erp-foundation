#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

# Phase5a proposal worker:
# - DOES NOT EXECUTE SQL
# - just marks one pending proposal as reviewed (idempotent-ish)

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
DO $$
DECLARE
  r record;
BEGIN
  -- NOTE: match actual schema of governance.policy_change_queue (proposal queue)
  SELECT
    policy_change_id,
    policy_key,
    proposed_action,
    proposed_value,
    confidence
  INTO r
  FROM governance.policy_change_queue
  WHERE status = 'pending'
  ORDER BY policy_change_id
  FOR UPDATE SKIP LOCKED
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  UPDATE governance.policy_change_queue
     SET status = 'reviewed'
   WHERE policy_change_id = r.policy_change_id;

  INSERT INTO governance.ops_event(severity, event_type, message, detail)
  VALUES ('info','proposal_reviewed','proposal marked reviewed',
          jsonb_build_object('policy_change_id', r.policy_change_id, 'policy_key', r.policy_key, 'confidence', r.confidence));
END $$;
SQL
