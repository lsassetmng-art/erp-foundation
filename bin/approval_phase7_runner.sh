#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

SLACK="${SLACK_WEBHOOK_URL:-}"
LINE="${LINE_WEBHOOK_URL:-}"

post_slack(){ [ -n "$SLACK" ] && curl -sS -X POST "$SLACK" -H 'Content-Type: application/json' -d "{\"text\":\"$1\"}" >/dev/null || echo "[SLACK] $1"; }
post_line(){  [ -n "$LINE"  ] && curl -sS -X POST "$LINE"  -H 'Content-Type: application/json' -d "{\"message\":\"$1\"}" >/dev/null || echo "[LINE] $1"; }

# ------------------------------------------------------------
# 1️⃣ BAD 検出（audit_trail 連動）
# ------------------------------------------------------------
BAD_COUNT="$(curl -sS -X POST \
  "$SUPABASE_URL/rest/v1/rpc/enqueue_rework_from_bad_all" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" -d '{}' | tr -dc '0-9')"
BAD_COUNT="${BAD_COUNT:-0}"

if [ "$BAD_COUNT" -gt 0 ]; then
  post_slack "🚨 BAD detected (audit_trail): $BAD_COUNT"
  post_line  "🚨 BAD detected (audit_trail): $BAD_COUNT"
  EXIT_BAD=101
else
  EXIT_BAD=0
fi

# ------------------------------------------------------------
# 2️⃣ 月次 ROI レポート（最新月）
# ------------------------------------------------------------
ROI="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_monthly_roi_report?order=month.desc&limit=5" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

post_slack "📊 Monthly AI ROI: $(echo "$ROI" | tr '\n' ' ')"
post_line  "📊 Monthly AI ROI: $(echo "$ROI" | tr '\n' ' ')"

# ------------------------------------------------------------
# 3️⃣ SaaS有効会社のみ autopilot 継続
#    （既存 approval_autopilot_company.sh があれば呼ぶ）
# ------------------------------------------------------------
if [ -x "$HOME/erp-foundation/bin/approval_autopilot_company.sh" ]; then
  "$HOME/erp-foundation/bin/approval_autopilot_company.sh" || true
fi

exit "$EXIT_BAD"
