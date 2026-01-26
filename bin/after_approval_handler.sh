#!/bin/sh
set -e

# ============================================================
# after_approval_handler.sh
# - approved / rejected 通知（注文詳細つき）
# - approved のみ pm_loop 再実行
# ============================================================

REQ_ID="${1:-}"
STATUS="${2:-}"   # approved | rejected

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"
PM_LOOP="$HOME/erp-foundation/bin/pm_loop.sh"

# ------------------------------------------------------------
# 承認結果＋注文サマリ取得
# ------------------------------------------------------------
JSON="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_approval_result_enriched?request_id=eq.$REQ_ID&limit=1" \
  -H "apikey: $KEY" \
  -H "Authorization: Bearer $KEY")"

ORDER_NO="$(echo "$JSON" | sed -n 's/.*"order_no":"\([^"]*\)".*/\1/p')"
TOTAL_AMOUNT="$(echo "$JSON" | sed -n 's/.*"total_amount":\([^,}]*\).*/\1/p')"
TOTAL_QTY="$(echo "$JSON" | sed -n 's/.*"total_qty":\([^,}]*\).*/\1/p')"
POLICY_ID="$(echo "$JSON" | sed -n 's/.*"policy_id":"\([^"]*\)".*/\1/p')"
SEVERITY="$(echo "$JSON" | sed -n 's/.*"severity":"\([^"]*\)".*/\1/p')"

# ------------------------------------------------------------
# 通知メッセージ
# ------------------------------------------------------------
case "$STATUS" in
  approved)
    MSG="✅ APPROVED order=$ORDER_NO amount=$TOTAL_AMOUNT qty=$TOTAL_QTY policy=$POLICY_ID"
    ;;
  rejected)
    MSG="❌ REJECTED order=$ORDER_NO amount=$TOTAL_AMOUNT qty=$TOTAL_QTY policy=$POLICY_ID"
    ;;
  *)
    exit 0
    ;;
esac

# Slack / LINE（既存 env を使用）
if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
  curl -sS -X POST "$SLACK_WEBHOOK_URL" \
    -H 'Content-Type: application/json' \
    -d "{\"text\":\"$MSG\"}" >/dev/null || true
else
  echo "[SLACK] $MSG"
fi

if [ -n "${LINE_WEBHOOK_URL:-}" ]; then
  curl -sS -X POST "$LINE_WEBHOOK_URL" \
    -H 'Content-Type: application/json' \
    -d "{\"message\":\"$MSG\"}" >/dev/null || true
else
  echo "[LINE] $MSG"
fi

# ------------------------------------------------------------
# approved のみ pm_loop 再実行
# ------------------------------------------------------------
if [ "$STATUS" = "approved" ]; then
  echo "▶ pm_loop restart (approved)"
  "$PM_LOOP" || true
fi

exit 0
