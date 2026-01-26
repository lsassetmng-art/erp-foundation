#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

ORDER_ID="$1"
ENTITY_ID="$2"

# ------------------------------------------------------------
# 1️⃣ AIルール適用判定（その注文だけ）
# ------------------------------------------------------------
APPLY_JSON="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_ai_rule_applicable_order?order_id=eq.$ORDER_ID&limit=1" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

if echo "$APPLY_JSON" | grep -q "auto_policy_id"; then
  AUTO_POLICY_ID="$(echo "$APPLY_JSON" | sed -n 's/.*"auto_policy_id":"\([^"]*\)".*/\1/p')"

  echo "AI auto-approval applied (policy=$AUTO_POLICY_ID)"

  # ----------------------------------------------------------
  # 2️⃣ OK 評価を自動記録
  # ----------------------------------------------------------
  curl -sS -X POST \
    "$SUPABASE_URL/rest/v1/approval.policy_eval_event" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"auto_policy_id\":\"$AUTO_POLICY_ID\",
      \"order_id\":$ORDER_ID,
      \"entity_id\":\"$ENTITY_ID\",
      \"outcome\":\"ok\"
    }" >/dev/null

  exit 70
fi

exit 0
