#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
SUPABASE_KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"
LLM_API_URL="${LLM_API_URL:?}"
LLM_API_KEY="${LLM_API_KEY:?}"

# ------------------------------------------------------------
# 1. AI入力取得
# ------------------------------------------------------------
INPUT_JSON="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_ai_llm_input?limit=5" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY")"

[ -z "$INPUT_JSON" ] && exit 0

# ------------------------------------------------------------
# 2. LLM 呼び出し（改善提案 + ルール生成）
# ------------------------------------------------------------
PROMPT="$(cat <<PROMPT
You are an approval optimization AI.

Given approval cases in JSON:
$INPUT_JSON

Tasks:
1. Summarize common approval delay reasons.
2. Propose concrete approval rule improvements.
3. Output ONE auto-approval rule in JSON with confidence_score (0-1).

Output format (JSON only):
{
  "summary": "...",
  "suggestion": "...",
  "auto_rule": {
    "condition": "...",
    "action": "auto_approve",
    "confidence_score": 0.0
  }
}
PROMPT
)"

LLM_RES="$(curl -sS "$LLM_API_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -d "{\"prompt\":$(printf '%s' "$PROMPT" | sed 's/"/\\"/g')}"
)"

echo "[LLM RESULT]"
echo "$LLM_RES"

# ------------------------------------------------------------
# 3. DBへ保存（summary / rule）
# ------------------------------------------------------------
SUMMARY="$(echo "$LLM_RES" | sed -n 's/.*"summary":"\([^"]*\)".*/\1/p')"
SUGGESTION="$(echo "$LLM_RES" | sed -n 's/.*"suggestion":"\([^"]*\)".*/\1/p')"
RULE_JSON="$(echo "$LLM_RES" | sed -n 's/.*"auto_rule":\({.*}\).*/\1/p')"
CONF="$(echo "$RULE_JSON" | sed -n 's/.*"confidence_score":\([0-9.]*\).*/\1/p')"

[ -z "$RULE_JSON" ] && exit 0

curl -sS -X POST \
  "$SUPABASE_URL/rest/v1/approval.policy_auto_generated" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"source_policy_id\":\"ai-derived\",
    \"generated_rule\":$RULE_JSON,
    \"confidence_score\":$CONF
  }" >/dev/null

exit 40
