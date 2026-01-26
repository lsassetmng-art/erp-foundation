-- ============================================================
-- Phase4: RLS/POLICY reinjection (idempotent) [FIXED]
-- ============================================================

DO $$
DECLARE
  r record;
  pol_name text;
BEGIN
  -- Ensure helper exists (if not, create safe stub)
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='my_company_id'
  ) THEN
    EXECUTE '
      CREATE OR REPLACE FUNCTION public.my_company_id()
      RETURNS uuid
      LANGUAGE sql
      STABLE
      AS $func$
        SELECT NULL::uuid
      $func$;
    ';
  END IF;

  -- Target tables: has company_id, and schema is not Supabase-managed
  FOR r IN
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
  LOOP
    EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.table_schema, r.table_name);

    pol_name := format('p_%s_%s_company', r.table_schema, r.table_name);
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname=r.table_schema AND tablename=r.table_name AND policyname=pol_name
    ) THEN
      EXECUTE format(
        'CREATE POLICY %I ON %I.%I
         FOR ALL TO authenticated
         USING (company_id = public.my_company_id())
         WITH CHECK (company_id = public.my_company_id())',
        pol_name, r.table_schema, r.table_name
      );
    END IF;

    pol_name := format('p_%s_%s_service_role_all', r.table_schema, r.table_name);
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname=r.table_schema AND tablename=r.table_name AND policyname=pol_name
    ) THEN
      EXECUTE format(
        'CREATE POLICY %I ON %I.%I
         FOR ALL TO service_role
         USING (true)
         WITH CHECK (true)',
        pol_name, r.table_schema, r.table_name
      );
    END IF;
  END LOOP;
END $$;
