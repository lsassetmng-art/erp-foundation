#!/bin/sh
set -eu

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"
TS="$(date +%Y%m%d-%H%M%S)"
OUT="$HOME/erp-foundation/reports/$TS"
mkdir -p "$OUT"

# 前年比
curl -sS "$SUPABASE_URL/rest/v1/approval.v_exec_dashboard_yoy?select=*" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY" -H "Accept: text/csv" \
  > "$OUT/exec_dashboard_yoy.csv"

# SLA分布
curl -sS "$SUPABASE_URL/rest/v1/approval.v_sla_distribution_monthly?select=*" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY" -H "Accept: text/csv" \
  > "$OUT/sla_distribution_monthly.csv"

echo "OK: $OUT"
exit 0
