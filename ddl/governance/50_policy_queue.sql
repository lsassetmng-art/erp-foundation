-- ============================================================
-- Phase5: policy change queue (idempotent)
-- ============================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS governance;

CREATE TABLE IF NOT EXISTS governance.policy_change_queue (
  change_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requested_at timestamptz NOT NULL DEFAULT now(),
  requested_by text NOT NULL DEFAULT current_user,
  title text NOT NULL,
  sql_text text NOT NULL,
  status text NOT NULL DEFAULT 'pending', -- pending|applied|rejected
  applied_at timestamptz,
  last_error text
);

CREATE INDEX IF NOT EXISTS policy_change_queue_status_idx
  ON governance.policy_change_queue(status, requested_at);

CREATE OR REPLACE FUNCTION governance.enqueue_policy_change(p_title text, p_sql text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO governance.policy_change_queue(title, sql_text)
  VALUES (p_title, p_sql)
  RETURNING change_id INTO v_id;
  RETURN v_id;
END $$;
