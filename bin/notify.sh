#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
MSG="${1:-}"
WEBHOOK="${ERP_WEBHOOK_URL:-}"
[ -z "$WEBHOOK" ] && exit 0
[ -z "$MSG" ] && exit 0

# minimal JSON escape (no python)
esc() {
  sed \
    -e 's/\\/\\\\/g' \
    -e 's/"/\\"/g' \
    -e $'s/\t/\\\\t/g' \
    -e $'s/\r/\\\\r/g' \
    -e $'s/\n/\\\\n/g'
}

BODY="$(printf '%s' "$MSG" | esc)"
curl -fsS -X POST -H 'Content-Type: application/json' \
  --data "{\"text\":\"$BODY\"}" \
  "$WEBHOOK" >/dev/null 2>&1 || true
