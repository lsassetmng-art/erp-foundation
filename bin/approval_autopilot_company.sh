#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

SLACK="${SLACK_WEBHOOK_URL:-}"
LINE="${LINE_WEBHOOK_URL:-}"

post_slack(){ [ -n "$SLACK" ] && curl -sS -X POST "$SLACK" -H 'Content-Type: application/json' -d "{\"text\":\"$1\"}" >/dev/null || echo "[SLACK] $1"; }
post_line(){  [ -n "$LINE"  ] && curl -sS -X POST "$LINE"  -H 'Content-Type: application/json' -d "{\"message\":\"$1\"}" >/dev/null || echo "[LINE] $1"; }

# ------------------------------------------------------------
# 1) 会社単位で autopilot ON の policy 取得
# ------------------------------------------------------------
ENABLED="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_autopilot_company_enabled" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

echo "$ENABLED" | grep -q "auto_policy_id" || exit 0

# ------------------------------------------------------------
# 2) BAD 拡張検出
# ------------------------------------------------------------
BAD_COUNT="$(curl -sS -X POST \
  "$SUPABASE_URL/rest/v1/rpc/enqueue_rework_from_bad_extended" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" -d '{}' | tr -dc '0-9')"
BAD_COUNT="${BAD_COUNT:-0}"

if [ "$BAD_COUNT" -gt 0 ]; then
  post_slack "🚨 BAD detected (manual edit / revert): $BAD_COUNT"
  post_line  "🚨 BAD detected (manual edit / revert): $BAD_COUNT"
  EXIT_BAD=91
else
  EXIT_BAD=0
fi

# ------------------------------------------------------------
# 3) ROI（円）トップ通知
# ------------------------------------------------------------
ROI="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_policy_roi_yen?order=savings_yen.desc&limit=3" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

post_slack "💰 AI Approval ROI (Top3): $(echo "$ROI" | tr '\n' ' ')"
post_line  "💰 AI Approval ROI (Top3): $(echo "$ROI" | tr '\n' ' ')"

exit "$EXIT_BAD"
