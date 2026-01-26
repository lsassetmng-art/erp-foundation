-- ============================================================
-- tenant.license_master → company-scoped
-- ============================================================

ALTER TABLE tenant.license_master
  ADD COLUMN IF NOT EXISTS company_id uuid;

UPDATE tenant.license_master
  SET company_id = public.my_company_id()
  WHERE company_id IS NULL;

ALTER TABLE tenant.license_master
  ALTER COLUMN company_id SET NOT NULL;
