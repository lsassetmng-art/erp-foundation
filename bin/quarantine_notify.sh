#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
Q="$ROOT/pm_ai/quarantine"

# どちらか設定（両方可）
# LINE_NOTIFY_TOKEN=xxxx
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...

msg() {
  echo "🚨 Task quarantined: $1"
}

for f in "$Q"/*; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  text="$(msg "$name")"

  if [ -n "${LINE_NOTIFY_TOKEN:-}" ]; then
    curl -s -X POST https://notify-api.line.me/api/notify \
      -H "Authorization: Bearer $LINE_NOTIFY_TOKEN" \
      -d "message=$text" >/dev/null || true
  fi

  if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    curl -s -X POST "$SLACK_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{\"text\":\"$text\"}" >/dev/null || true
  fi
done

exit 0
