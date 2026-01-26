-- ============================================================
-- system.* add company_id (safe, idempotent)
-- ============================================================

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema = 'system'
      AND table_type = 'BASE TABLE'
      AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns c
        WHERE c.table_schema = table_schema
          AND c.table_name   = table_name
          AND c.column_name  = 'company_id'
      )
  LOOP
    EXECUTE format(
      'ALTER TABLE %I.%I ADD COLUMN company_id uuid;',
      r.table_schema, r.table_name
    );

    EXECUTE format(
      'UPDATE %I.%I SET company_id = public.my_company_id() WHERE company_id IS NULL;',
      r.table_schema, r.table_name
    );

    EXECUTE format(
      'ALTER TABLE %I.%I ALTER COLUMN company_id SET NOT NULL;',
      r.table_schema, r.table_name
    );
  END LOOP;
END$$;
