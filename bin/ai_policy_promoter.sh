#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

# ------------------------------------------------------------
# 1️⃣ 自動有効化
# ------------------------------------------------------------
AUTO_JSON="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_auto_policy_activate" \
  -H "apikey: $KEY" \
  -H "Authorization: Bearer $KEY")"

echo "$AUTO_JSON" | grep -q "auto_policy_id" || exit 0

IDS="$(echo "$AUTO_JSON" | sed -n 's/.*"auto_policy_id":"\([^"]*\)".*/\1/p')"

for ID in $IDS; do
  # activated=true
  curl -sS -X PATCH \
    "$SUPABASE_URL/rest/v1/approval.policy_auto_generated?auto_policy_id=eq.$ID" \
    -H "apikey: $KEY" \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d '{"activated":true}' >/dev/null

  # activation log
  curl -sS -X POST \
    "$SUPABASE_URL/rest/v1/approval.policy_activation_log" \
    -H "apikey: $KEY" \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "{\"auto_policy_id\":\"$ID\"}" >/dev/null
done

# ------------------------------------------------------------
# 2️⃣ Layer2 lint 用 policy JSON 生成（安全・読み取り）
# ------------------------------------------------------------
POLICY_JSON="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_layer2_active_policies" \
  -H "apikey: $KEY" \
  -H "Authorization: Bearer $KEY")"

echo "[ACTIVE POLICIES FOR LAYER2]"
echo "$POLICY_JSON"

# ------------------------------------------------------------
# 3️⃣ ABテスト結果
# ------------------------------------------------------------
AB_JSON="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_policy_ab_test" \
  -H "apikey: $KEY" \
  -H "Authorization: Bearer $KEY")"

echo "[AB TEST RESULT]"
echo "$AB_JSON"

exit 50
