#!/bin/bash
set -e

SPEC="spec/usecases.schema.yaml"
OUT="reports/spec_diff_ai_summary.md"

DIFF=$(git diff -- "$SPEC" || true)
[ -z "$DIFF" ] && exit 0

# OPENAI_API_KEY 必須（CI/ローカル共通）
[ -z "$OPENAI_API_KEY" ] && exit 0

PROMPT=$(cat <<EOF
次のYAML差分を、人間のリーダー向けに日本語で要約してください。
・何が変わったか
・影響範囲
・破壊的変更の可能性
・推奨アクション

差分:
$DIFF
EOF
)

curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"gpt-4o-mini\",
    \"messages\": [
      {\"role\": \"system\", \"content\": \"あなたは厳格な技術レビュアーです\"},
      {\"role\": \"user\", \"content\": \"${PROMPT//\"/\\\"}\"}
    ],
    \"temperature\": 0
  }" \
| jq -r '.choices[0].message.content' > "$OUT"
