#!/bin/sh
set -eu

BASE="$HOME/erp-foundation"
LOG="$BASE/logs/billing.log"

echo "[billing] start" >> "$LOG"

# 1️⃣ Stripe Webhook（Edge Function 側でDB反映済み前提）
# → ここでは「今月分請求生成」をトリガ

MONTH=$(date '+%Y-%m-01')

psql "$DATABASE_URL" <<SQL
insert into billing.invoice (company_id, billing_month, total_amount)
select
  company_id,
  '$MONTH'::date,
  approval_requests * 100   -- 仮：100円/件（後でStripe価格と同期）
from billing.v_monthly_usage
where month = '$MONTH'::date
on conflict do nothing;
SQL

# 2️⃣ 請求PDF生成（ダミー：URLだけ発行）
psql "$DATABASE_URL" <<SQL
update billing.invoice
   set pdf_url = 'https://example.com/invoice/' || invoice_id || '.pdf',
       status = 'sent'
 where billing_month = '$MONTH'::date;
SQL

# 3️⃣ 承認AI経営ダッシュボード用通知
psql "$DATABASE_URL" <<SQL
select * from approval.v_exec_dashboard;
SQL

echo "[billing] done" >> "$LOG"
exit 0
