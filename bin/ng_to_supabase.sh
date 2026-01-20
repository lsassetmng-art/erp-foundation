#!/bin/sh
set -eu

: "${SUPABASE_URL:?not set}"
: "${SUPABASE_ANON_KEY:?not set}"

ROOT="$HOME/erp-foundation"
LOG="$ROOT/logs/pm_lint.last"

NG="$(sed 's/.*NG: //' "$LOG")"
NOW="$(date -Is)"

curl -s "$SUPABASE_URL/rest/v1/ng_event" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"occurred_at\": \"$NOW\",
    \"reason\": \"$NG\"
  }" >/dev/null

exit 0
