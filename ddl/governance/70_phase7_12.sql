-- ============================================================
-- Phase7-12: Governance add-ons (NON-BREAKING)
-- ============================================================

CREATE SCHEMA IF NOT EXISTS governance;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ----------------------------
-- Autonomy config (Phase12)
-- ----------------------------
CREATE TABLE IF NOT EXISTS governance.autonomy_config (
  config_id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  updated_at          timestamptz NOT NULL DEFAULT now(),
  updated_by          text        NOT NULL DEFAULT current_user,

  autonomy_mode       text        NOT NULL DEFAULT 'manual',  -- manual|auto
  min_confidence      numeric(4,3) NOT NULL DEFAULT 0.900,
  max_risk_score      numeric(6,3) NOT NULL DEFAULT 0.300,
  require_dryrun_ok   boolean     NOT NULL DEFAULT true,      -- if false: allow dryrun skipped
  auto_enqueue_apply  boolean     NOT NULL DEFAULT true
);

-- ensure 1 row exists
INSERT INTO governance.autonomy_config(autonomy_mode)
SELECT 'manual'
WHERE NOT EXISTS (SELECT 1 FROM governance.autonomy_config);

-- ----------------------------
-- Action log (Phase9)
-- ----------------------------
CREATE TABLE IF NOT EXISTS governance.governance_action_log (
  action_id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  at            timestamptz NOT NULL DEFAULT now(),
  actor         text        NOT NULL DEFAULT current_user,
  action_type   text        NOT NULL, -- proposal_reviewed|approval_created|approval_notified|approved|rejected|apply_enqueued|applied|failed|dryrun_done
  ref_type      text        NOT NULL, -- policy_change|approval|apply
  ref_id        bigint,
  payload       jsonb       NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS governance_action_log_at_idx
  ON governance.governance_action_log(at DESC);

-- ----------------------------
-- Approval queue (Phase7)
--  proposal(reviewed) -> approval(pending) -> approved/rejected -> apply_queue
-- ----------------------------
CREATE TABLE IF NOT EXISTS governance.policy_approval_queue (
  approval_id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at           timestamptz NOT NULL DEFAULT now(),
  created_by           text        NOT NULL DEFAULT current_user,

  policy_change_id     bigint, -- links to governance.policy_change_queue.policy_change_id
  title                text        NOT NULL,
  sql_text             text        NOT NULL,

  confidence           numeric(6,3),
  risk_score           numeric(6,3),
  dryrun_status        text        NOT NULL DEFAULT 'pending',  -- pending|ok|skipped|failed
  dryrun_plan_json     jsonb,
  dryrun_error         text,

  status               text        NOT NULL DEFAULT 'pending',  -- pending|approved|rejected|enqueued|applied
  decided_at           timestamptz,
  decided_by           text,
  decision_note        text,

  notified_at          timestamptz,
  applied_apply_id     bigint,
  last_error           text
);

CREATE INDEX IF NOT EXISTS policy_approval_queue_status_idx
  ON governance.policy_approval_queue(status, created_at);

-- ----------------------------
-- Learning feedback (Phase10)
-- ----------------------------
CREATE TABLE IF NOT EXISTS governance.policy_learning_event (
  learn_id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  at              timestamptz NOT NULL DEFAULT now(),
  policy_change_id bigint,
  approval_id     bigint,
  apply_id        bigint,
  confidence      numeric(6,3),
  risk_score      numeric(6,3),
  outcome         text NOT NULL, -- approved|rejected|applied|failed
  note            text,
  payload         jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS policy_learning_event_at_idx
  ON governance.policy_learning_event(at DESC);

-- ----------------------------
-- Phase8: Dry-run / risk scoring helpers
--  - EXPLAIN only for DML (SELECT/INSERT/UPDATE/DELETE).
--  - DDL returns "skipped" (still can be approved manually/auto by config).
-- ----------------------------
CREATE OR REPLACE FUNCTION governance.risk_score(p_sql text)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
  s text := lower(coalesce(p_sql,''));
  score numeric := 0.000;
BEGIN
  -- very rough heuristic
  IF s ~ '\bdrop\b' THEN score := greatest(score, 0.950); END IF;
  IF s ~ '\balter\s+table\b' THEN score := greatest(score, 0.700); END IF;
  IF s ~ '\bcreate\s+index\b' THEN score := greatest(score, 0.450); END IF;
  IF s ~ '\btruncate\b' THEN score := greatest(score, 0.950); END IF;
  IF s ~ '\bdelete\b' THEN score := greatest(score, 0.650); END IF;
  IF s ~ '\bupdate\b' THEN score := greatest(score, 0.550); END IF;
  IF s ~ '\binsert\b' THEN score := greatest(score, 0.350); END IF;
  IF s ~ '\bgrant\b|\brevoke\b|\bcreate\s+policy\b|\balter\s+policy\b|\bdrop\s+policy\b' THEN
    score := greatest(score, 0.600);
  END IF;
  IF s ~ '\bcreate\s+table\b' THEN score := greatest(score, 0.500); END IF;
  IF s ~ '\bselect\b' AND score < 0.200 THEN score := greatest(score, 0.100); END IF;
  RETURN score;
END $$;

CREATE OR REPLACE FUNCTION governance.try_dryrun_explain(p_sql text)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  s text := ltrim(coalesce(p_sql,''));
  head text := lower(coalesce(substring(s from '^[a-zA-Z]+'), ''));
  v_plan json;
BEGIN
  IF head IN ('select','insert','update','delete') THEN
    BEGIN
      EXECUTE 'EXPLAIN (FORMAT JSON) ' || p_sql INTO v_plan;
      RETURN jsonb_build_object('status','ok','plan', to_jsonb(v_plan));
    EXCEPTION WHEN OTHERS THEN
      RETURN jsonb_build_object('status','failed','error', SQLERRM);
    END;
  ELSE
    RETURN jsonb_build_object('status','skipped','reason','ddl_or_unknown');
  END IF;
END $$;

-- ----------------------------
-- Phase11: KPI views
-- ----------------------------
CREATE OR REPLACE VIEW governance.v_kpi_daily AS
WITH d AS (
  SELECT date_trunc('day', at) AS day, outcome, count(*) AS cnt
  FROM governance.policy_learning_event
  GROUP BY 1,2
)
SELECT
  day,
  sum(cnt) FILTER (WHERE outcome='approved') AS approved,
  sum(cnt) FILTER (WHERE outcome='rejected') AS rejected,
  sum(cnt) FILTER (WHERE outcome='applied')  AS applied,
  sum(cnt) FILTER (WHERE outcome='failed')   AS failed,
  sum(cnt) AS total
FROM d
GROUP BY day
ORDER BY day DESC;

