#!/bin/sh
set -eu

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

YM="$(date +%Y%m)"

# ------------------------------------------------------------
# 1) 月次利用量集計（承認数）
#    ※ approval_request を正本とする
# ------------------------------------------------------------
USAGE="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval_request?select=company_id,order_id&status=in.(approved,rejected)" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

# 会社→subscription を引いて usage を増やす（簡易）
echo "$USAGE" | sed -n 's/.*"company_id":"\([^"]*\)".*/\1/p' | sort | uniq | while read CID; do
  SUB="$(curl -s \
    "$SUPABASE_URL/rest/v1/approval.saas_company_map?company_id=eq.$CID&select=subscription_id&limit=1" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" | sed -n 's/.*"subscription_id":"\([^"]*\)".*/\1/p')"
  [ -z "$SUB" ] && continue

  # upsert usage
  curl -sS -X POST \
    "$SUPABASE_URL/rest/v1/approval.saas_usage_monthly" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"subscription_id\":\"$SUB\",
      \"ym\":\"$YM\",
      \"approvals_count\":1
    }" >/dev/null || true
done

# ------------------------------------------------------------
# 2) 上限チェック
# ------------------------------------------------------------
LIMITS="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_saas_limit_status" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

if echo "$LIMITS" | grep -q "Monthly approval limit exceeded"; then
  exit 121
fi

# ------------------------------------------------------------
# 3) 請求書（draft）生成
# ------------------------------------------------------------
SUBS="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.saas_subscription?status=eq.active" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

echo "$SUBS" | sed -n 's/.*"customer_code":"\([^"]*\)".*/\1/p' | while read CUST; do
  curl -sS -X POST \
    "$SUPABASE_URL/rest/v1/approval.billing_invoice" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"customer_code\":\"$CUST\",
      \"ym\":\"$YM\",
      \"amount_yen\":0,
      \"status\":\"draft\"
    }" >/dev/null
done

exit 122
