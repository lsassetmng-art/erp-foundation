#!/bin/sh
set -eu

BASE="$HOME/erp-foundation"
cd "$BASE" >/dev/null 2>&1 || true

echo "Created Edge Functions:"
echo " - supabase/functions/stripe-webhook"
echo " - supabase/functions/send-invoice"
echo " - supabase/functions/public-site"

# supabase CLI があればデプロイ（無ければ exit 2）
if ! command -v supabase >/dev/null 2>&1; then
  echo "WARN: supabase CLI not found. Files are ready but not deployed."
  exit 2
fi

# 必須環境変数（デプロイ後にSupabase側で secrets 設定が必要）
# STRIPE_WEBHOOK_SECRET, RESEND_API_KEY, INVOICE_FROM_EMAIL は必須
MISSING=0
for v in SUPABASE_URL SUPABASE_SERVICE_ROLE_KEY; do
  eval "val=\${$v:-}"
  if [ -z "$val" ]; then
    echo "WARN: missing env $v (only needed for local tests; deployment uses Supabase secrets)"
    MISSING=1
  fi
done
[ "$MISSING" -eq 1 ] && exit 3 || true

# deploy
supabase functions deploy stripe-webhook
supabase functions deploy send-invoice
supabase functions deploy public-site

echo "OK: deployed."
exit 0
