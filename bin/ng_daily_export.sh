#!/bin/sh
set -eu
: "${SUPABASE_URL:?not set}"
: "${SUPABASE_ANON_KEY:?not set}"

OUT="$HOME/erp-foundation/public/ng_daily.json"

curl -s "$SUPABASE_URL/rest/v1/v_ng_daily_count?order=day" \
 -H "apikey: $SUPABASE_ANON_KEY" \
 -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
 > "$OUT"
exit 0
