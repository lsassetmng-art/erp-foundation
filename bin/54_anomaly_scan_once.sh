#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
DO $$
DECLARE
  v_missing_rls integer := 0;
  v_pending_age_sec numeric := 0;
BEGIN
  -- missing RLS count on company_id tables (app schemas)
  WITH targets AS (
    SELECT c.table_schema, c.table_name
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema=c.table_schema AND t.table_name=c.table_name
    WHERE c.column_name='company_id'
      AND t.table_type='BASE TABLE'
      AND c.table_schema NOT IN (
        'pg_catalog','information_schema',
        'auth','storage','realtime','supabase_functions','extensions',
        'graphql','pgbouncer'
      )
      AND c.table_schema NOT LIKE 'pg_%'
  ),
  flags AS (
    SELECT n.nspname AS table_schema, cls.relname AS table_name, cls.relrowsecurity AS rls_enabled
    FROM pg_class cls
    JOIN pg_namespace n ON n.oid=cls.relnamespace
    JOIN targets t ON t.table_schema=n.nspname AND t.table_name=cls.relname
    WHERE cls.relkind='r'
  )
  SELECT count(*) INTO v_missing_rls
  FROM flags
  WHERE NOT rls_enabled;

  IF v_missing_rls > 0 THEN
    INSERT INTO governance.ops_event(severity, event_type, message, detail)
    VALUES ('error','anomaly_missing_rls','some company_id tables missing RLS',
            jsonb_build_object('missing_count', v_missing_rls));
  END IF;

  -- pending apply age (max seconds)
  SELECT coalesce(extract(epoch from (now() - min(requested_at))),0)
    INTO v_pending_age_sec
  FROM governance.policy_apply_queue
  WHERE status='pending';

  IF v_pending_age_sec > 600 THEN
    INSERT INTO governance.ops_event(severity, event_type, message, detail)
    VALUES ('warn','anomaly_apply_pending_age','apply queue pending too long',
            jsonb_build_object('oldest_pending_age_sec', v_pending_age_sec));
  END IF;
END $$;
SQL
