#!/bin/sh
set -eu
SUPABASE_URL="${SUPABASE_URL:?}"
ANON="${SUPABASE_ANON_KEY:-}"

# public LP
curl -sS "$SUPABASE_URL/functions/v1/public-lp?lang=ja" ${ANON:+-H "apikey: $ANON"} >/dev/null
curl -sS "$SUPABASE_URL/functions/v1/public-lp?lang=en" ${ANON:+-H "apikey: $ANON"} >/dev/null

echo "OK: public-lp reachable"
exit 0
