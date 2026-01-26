#!/bin/sh
set -eu

# ============================================================
# notify_after_approval.sh
# - approved / rejected を本物通知
# - severity / policy_id 別分岐
# ============================================================

REQ_ID="${1:-}"
STATUS="${2:-}"      # approved | rejected
ORDER_NO="${3:-unknown}"
POLICY_ID="${4:-unknown}"
SEVERITY="${5:-low}"

# ---- メッセージ ----
case "$STATUS" in
  approved)
    MSG="✅ APPROVED order=$ORDER_NO policy=$POLICY_ID"
    ;;
  rejected)
    MSG="❌ REJECTED order=$ORDER_NO policy=$POLICY_ID"
    ;;
  *)
    exit 0
    ;;
esac

# ---- 通知先分岐 ----
# severity=high → *_CRITICAL
# policy_id 専用 → *_POLICY_<ID>
# default → *_URL

# Slack
SLACK_URL=""
if [ "$SEVERITY" = "high" ] && [ -n "${SLACK_WEBHOOK_CRITICAL:-}" ]; then
  SLACK_URL="$SLACK_WEBHOOK_CRITICAL"
elif [ -n "$(eval echo "\${SLACK_WEBHOOK_POLICY_${POLICY_ID}:-}")" ]; then
  SLACK_URL="$(eval echo "\$SLACK_WEBHOOK_POLICY_${POLICY_ID}")"
else
  SLACK_URL="${SLACK_WEBHOOK_URL:-}"
fi

# LINE
LINE_URL=""
if [ "$SEVERITY" = "high" ] && [ -n "${LINE_WEBHOOK_CRITICAL:-}" ]; then
  LINE_URL="$LINE_WEBHOOK_CRITICAL"
elif [ -n "$(eval echo "\${LINE_WEBHOOK_POLICY_${POLICY_ID}:-}")" ]; then
  LINE_URL="$(eval echo "\$LINE_WEBHOOK_POLICY_${POLICY_ID}")"
else
  LINE_URL="${LINE_WEBHOOK_URL:-}"
fi

# ---- 送信（失敗しても落ちない） ----
if [ -n "$SLACK_URL" ]; then
  curl -sS -X POST "$SLACK_URL" \
    -H 'Content-Type: application/json' \
    -d "{\"text\":\"$MSG\"}" >/dev/null || true
else
  echo "📣 [SLACK STUB] $MSG"
fi

if [ -n "$LINE_URL" ]; then
  curl -sS -X POST "$LINE_URL" \
    -H 'Content-Type: application/json' \
    -d "{\"message\":\"$MSG\"}" >/dev/null || true
else
  echo "📣 [LINE STUB] $MSG"
fi

exit 0
