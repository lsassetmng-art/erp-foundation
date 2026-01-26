-- ============================================================
-- Phase14-20: Foundation Governance Hardening (idempotent)
-- - No destructive changes
-- - Additive tables/columns only
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS governance;

-- ------------------------------------------------------------
-- Phase20: foundation freeze (single source of truth)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS governance.freeze_state (
  freeze_id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  enabled     boolean NOT NULL DEFAULT false,
  reason      text,
  updated_by  text NOT NULL DEFAULT current_user,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS freeze_state_latest_idx
  ON governance.freeze_state(updated_at DESC);

CREATE OR REPLACE FUNCTION governance.is_frozen()
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
  SELECT coalesce((SELECT enabled FROM governance.freeze_state ORDER BY updated_at DESC LIMIT 1), false);
$$;

-- ------------------------------------------------------------
-- Phase19: multi-ai registry + distributed lock (DB lock)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS governance.ai_actor_registry (
  actor_id     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_name   text NOT NULL,
  actor_type   text NOT NULL DEFAULT 'ai', -- ai|human|service
  is_active    boolean NOT NULL DEFAULT true,
  created_at   timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz
);

CREATE TABLE IF NOT EXISTS governance.execution_lock (
  lock_key     text PRIMARY KEY,
  holder       text NOT NULL,
  acquired_at  timestamptz NOT NULL DEFAULT now(),
  ttl_sec      integer NOT NULL DEFAULT 60
);

CREATE OR REPLACE FUNCTION governance.try_acquire_lock(p_lock_key text, p_holder text, p_ttl_sec integer DEFAULT 60)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
  -- purge expired lock
  DELETE FROM governance.execution_lock
   WHERE lock_key = p_lock_key
     AND acquired_at + make_interval(secs => ttl_sec) < now();

  -- try insert
  INSERT INTO governance.execution_lock(lock_key, holder, acquired_at, ttl_sec)
  VALUES (p_lock_key, p_holder, now(), greatest(p_ttl_sec, 5))
  ON CONFLICT (lock_key) DO NOTHING;

  RETURN EXISTS (SELECT 1 FROM governance.execution_lock WHERE lock_key=p_lock_key AND holder=p_holder);
END $$;

CREATE OR REPLACE FUNCTION governance.release_lock(p_lock_key text, p_holder text)
RETURNS void
LANGUAGE sql
AS $$
  DELETE FROM governance.execution_lock WHERE lock_key=p_lock_key AND holder=p_holder;
$$;

-- ------------------------------------------------------------
-- Phase14: policy execution log (who executed what, when, result)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS governance.policy_execution_log (
  exec_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apply_id       bigint,
  source_change_id bigint,
  title          text,
  sql_text       text NOT NULL,
  executor       text NOT NULL DEFAULT current_user,
  executor_type  text NOT NULL DEFAULT 'service', -- service|ai|human
  autonomy_mode  text,
  dryrun_status  text, -- ok|skipped|failed
  status         text NOT NULL DEFAULT 'started', -- started|applied|rejected|rolled_back
  started_at     timestamptz NOT NULL DEFAULT now(),
  finished_at    timestamptz,
  last_error     text
);

CREATE INDEX IF NOT EXISTS policy_execution_log_started_idx
  ON governance.policy_execution_log(started_at DESC);

-- ------------------------------------------------------------
-- Align existing apply queue if already exists (safe adds)
-- NOTE: your apply_id is bigint identity already (OK)
-- ------------------------------------------------------------
DO $$
BEGIN
  IF to_regclass('governance.policy_apply_queue') IS NOT NULL THEN
    -- add missing columns safely (if you created earlier version)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema='governance' AND table_name='policy_apply_queue' AND column_name='dryrun_status') THEN
      ALTER TABLE governance.policy_apply_queue ADD COLUMN dryrun_status text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema='governance' AND table_name='policy_apply_queue' AND column_name='risk_score') THEN
      ALTER TABLE governance.policy_apply_queue ADD COLUMN risk_score numeric(8,3);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema='governance' AND table_name='policy_apply_queue' AND column_name='confidence') THEN
      ALTER TABLE governance.policy_apply_queue ADD COLUMN confidence numeric(8,3);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema='governance' AND table_name='policy_apply_queue' AND column_name='executor_hint') THEN
      ALTER TABLE governance.policy_apply_queue ADD COLUMN executor_hint text;
    END IF;
  END IF;
END $$;

-- ------------------------------------------------------------
-- Phase15: dry-run result container (lightweight)
-- (real EXPLAIN/transactional simulation can be enhanced later)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS governance.policy_dryrun_result (
  dryrun_id     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apply_id      bigint NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  status        text NOT NULL DEFAULT 'skipped', -- ok|skipped|failed
  notes         text,
  last_error    text
);

CREATE INDEX IF NOT EXISTS policy_dryrun_result_apply_idx
  ON governance.policy_dryrun_result(apply_id, created_at DESC);

-- ------------------------------------------------------------
-- Phase16: feedback (learning signal)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS governance.policy_feedback (
  feedback_id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apply_id      bigint,
  source_change_id bigint,
  created_at    timestamptz NOT NULL DEFAULT now(),
  actor         text NOT NULL DEFAULT current_user,
  outcome       text NOT NULL, -- good|bad|rollback|override
  confidence_delta numeric(8,3),
  risk_delta      numeric(8,3),
  note          text
);

CREATE INDEX IF NOT EXISTS policy_feedback_created_idx
  ON governance.policy_feedback(created_at DESC);

-- ------------------------------------------------------------
-- Phase17: ops/anomaly (events + minimal rules)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS governance.ops_event (
  event_id    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at  timestamptz NOT NULL DEFAULT now(),
  severity    text NOT NULL DEFAULT 'info', -- info|warn|error|critical
  event_type  text NOT NULL,
  message     text NOT NULL,
  detail      jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS ops_event_created_idx
  ON governance.ops_event(created_at DESC);

CREATE TABLE IF NOT EXISTS governance.anomaly_rule (
  rule_id     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  is_active   boolean NOT NULL DEFAULT true,
  rule_key    text NOT NULL UNIQUE,
  severity    text NOT NULL DEFAULT 'warn',
  threshold   numeric(20,3),
  window_sec  integer NOT NULL DEFAULT 300,
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- Default rules (safe upsert style)
INSERT INTO governance.anomaly_rule(rule_key, severity, threshold, window_sec)
VALUES
  ('missing_rls_tables', 'error', 0, 3600),
  ('apply_queue_pending_age_sec', 'warn', 600, 3600)
ON CONFLICT (rule_key) DO NOTHING;

-- ------------------------------------------------------------
-- Phase18: rollback planning/execution container
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS governance.rollback_plan (
  rollback_id  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at   timestamptz NOT NULL DEFAULT now(),
  created_by   text NOT NULL DEFAULT current_user,
  apply_id     bigint,
  title        text NOT NULL,
  rollback_sql text NOT NULL,
  status       text NOT NULL DEFAULT 'ready' -- ready|executed|failed
);

CREATE INDEX IF NOT EXISTS rollback_plan_created_idx
  ON governance.rollback_plan(created_at DESC);

CREATE TABLE IF NOT EXISTS governance.rollback_execution_log (
  exec_id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rollback_id  uuid NOT NULL,
  started_at   timestamptz NOT NULL DEFAULT now(),
  finished_at  timestamptz,
  status       text NOT NULL DEFAULT 'started', -- started|executed|failed
  last_error   text
);

CREATE INDEX IF NOT EXISTS rollback_exec_started_idx
  ON governance.rollback_execution_log(started_at DESC);

-- ------------------------------------------------------------
-- Helper view: quick status
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW governance.v_foundation_status AS
SELECT
  now() AS ts,
  governance.is_frozen() AS is_frozen,
  (SELECT count(*) FROM governance.policy_apply_queue WHERE status='pending') AS apply_pending,
  (SELECT count(*) FROM governance.policy_change_queue WHERE status='pending') AS proposal_pending
;

