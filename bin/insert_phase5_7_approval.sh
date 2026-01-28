#!/bin/sh
set -e

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
BEGIN;

-- ============================================================
-- Phase5–7 設計 承認（governance.approval_request）
-- ※ 実DDL準拠（request_type なし）
-- ============================================================
INSERT INTO governance.approval_request (
  company_id,
  status,
  requested_by,
  requested_at,
  decided_by,
  decided_at,
  reason
) VALUES (
  '<COMPANY_ID>',
  'approved',
  'system',
  now(),
  'knight',
  now(),
  'send_back 業務定義を明文化し、全観点で問題なしと判断'
);

-- ============================================================
-- 監査証跡（core.audit_trail）
-- ============================================================
INSERT INTO core.audit_trail (
  company_id,
  entity_type,
  entity_id,
  action,
  detail,
  performed_by,
  performed_at
) VALUES (
  '<COMPANY_ID>',
  'design',
  'phase5-7',
  'approve',
  jsonb_build_object(
    'final_decision', 'approve',
    'send_back_behavior', 'review_pending → 業務停止 → 修正後自動再レビュー',
    'reviewers', jsonb_build_array('sato','moran','tanaka','yamada','han','miho'),
    'chair', 'knight'
  ),
  NULL,
  now()
);

COMMIT;
SQL

echo "[OK] Phase5–7 approval inserted safely."
