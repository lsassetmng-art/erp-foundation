#!/bin/sh
set -eu

: "${OPENAI_API_KEY:?not set}"

ROOT="$HOME/erp-foundation"
DONE="$ROOT/pm_ai/done"
INBOX="$ROOT/pm_ai/inbox"

TASK="$(ls "$DONE"/* 2>/dev/null | tail -n 1)"
[ -f "$TASK" ] || exit 0

PROMPT="$(cat "$TASK")"
OUT="$INBOX/$(basename "$TASK")"

RESPONSE="$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"gpt-4.1-mini\",
    \"messages\": [
      {\"role\": \"system\", \"content\": \"You are an autonomous AI employee. Fix the task to satisfy policy.yaml. Do not ask questions.\"},
      {\"role\": \"user\", \"content\": \"$PROMPT\"}
    ]
  }")"

echo "$RESPONSE" \
  | sed -n 's/.*\"content\":\"\\(.*\\)\".*/\\1/p' \
  | sed 's/\\\\n/\n/g' > "$OUT"

exit 0
