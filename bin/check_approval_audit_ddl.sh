#!/bin/sh
set -e

# ============================================================
# approval_request / audit_trail
# DDL / company_id / RLS 確認
# ============================================================

psql "$DATABASE_URL" <<'SQL'

-- ------------------------------------------------------------
-- 1) approval_request 定義確認
-- ------------------------------------------------------------
SELECT
  table_schema,
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'approval_request'
ORDER BY ordinal_position;

-- ------------------------------------------------------------
-- 2) audit_trail 定義確認
-- ------------------------------------------------------------
SELECT
  table_schema,
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'audit_trail'
ORDER BY ordinal_position;

-- ------------------------------------------------------------
-- 3) company_id 有無確認
-- ------------------------------------------------------------
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_name IN ('approval_request','audit_trail')
  AND column_name = 'company_id';

-- ------------------------------------------------------------
-- 4) RLS 有効化確認
-- ------------------------------------------------------------
SELECT
  relname AS table_name,
  relrowsecurity AS rls_enabled
FROM pg_class
WHERE relname IN ('approval_request','audit_trail');

\q
SQL

echo "[OK] DDL check finished."
