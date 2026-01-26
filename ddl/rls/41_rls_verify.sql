-- ============================================================
-- Phase4 verify (FIXED: flags CTE is single-statement scope)
-- ============================================================

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
  SELECT
    n.nspname AS table_schema,
    cls.relname AS table_name,
    cls.relrowsecurity AS rls_enabled
  FROM pg_class cls
  JOIN pg_namespace n ON n.oid=cls.relnamespace
  JOIN targets t ON t.table_schema=n.nspname AND t.table_name=cls.relname
  WHERE cls.relkind='r'
)

SELECT
  count(*)                                       AS target_tables,
  count(*) FILTER (WHERE rls_enabled)            AS rls_enabled_tables,
  count(*) FILTER (WHERE NOT rls_enabled)        AS rls_missing_tables
FROM flags;

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
  SELECT
    n.nspname AS table_schema,
    cls.relname AS table_name,
    cls.relrowsecurity AS rls_enabled
  FROM pg_class cls
  JOIN pg_namespace n ON n.oid=cls.relnamespace
  JOIN targets t ON t.table_schema=n.nspname AND t.table_name=cls.relname
  WHERE cls.relkind='r'
)
SELECT table_schema, table_name
FROM flags
WHERE NOT rls_enabled
ORDER BY table_schema, table_name;
