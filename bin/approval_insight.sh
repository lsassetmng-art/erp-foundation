#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

# ------------------------------------------------------------
# 1. 承認ボトルネック
# ------------------------------------------------------------
BOTTLENECK="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_bottleneck_policy?order=avg_sla_minutes.desc&limit=3" \
  -H "apikey: $KEY" \
  -H "Authorization: Bearer $KEY")"

echo "[BOTTLENECK]"
echo "$BOTTLENECK"

# ------------------------------------------------------------
# 2. SLA エスカレーション
# ------------------------------------------------------------
ESC_JSON="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_sla_escalation?limit=3" \
  -H "apikey: $KEY" \
  -H "Authorization: Bearer $KEY")"

if echo "$ESC_JSON" | grep -q "request_id"; then
  MSG="🚨 SLA ESCALATION detected: $(echo "$ESC_JSON" | tr '\n' ' ')"

  [ -n "${SLACK_WEBHOOK_URL:-}" ] && \
    curl -sS -X POST "$SLACK_WEBHOOK_URL" \
      -H 'Content-Type: application/json' \
      -d "{\"text\":\"$MSG\"}" >/dev/null || echo "[SLACK] $MSG"

  [ -n "${LINE_WEBHOOK_URL:-}" ] && \
    curl -sS -X POST "$LINE_WEBHOOK_URL" \
      -H 'Content-Type: application/json' \
      -d "{\"message\":\"$MSG\"}" >/dev/null || echo "[LINE] $MSG"

  exit 30
fi

# ------------------------------------------------------------
# 3. AI 改善提案（スタブ）
# ------------------------------------------------------------
AI_INPUT="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_ai_improvement_input?limit=3" \
  -H "apikey: $KEY" \
  -H "Authorization: Bearer $KEY")"

echo "[AI IMPROVEMENT INPUT]"
echo "$AI_INPUT"

exit 0
