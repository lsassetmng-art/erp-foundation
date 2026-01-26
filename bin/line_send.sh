#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
: "${LINE_NOTIFY_TOKEN:?LINE_NOTIFY_TOKEN is required}"

MSG="${1:-}"
[ -n "$MSG" ] || { log NG "message empty"; exit 2; }

curl -sS -X POST "https://notify-api.line.me/api/notify" \
  -H "Authorization: Bearer ${LINE_NOTIFY_TOKEN}" \
  -d "message=${MSG}" >/dev/null

log OK "line sent"
