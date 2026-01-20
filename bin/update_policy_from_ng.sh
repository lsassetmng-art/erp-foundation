#!/bin/sh
set -eu

: "${SUPABASE_URL:?not set}"
: "${SUPABASE_ANON_KEY:?not set}"

ROOT="$HOME/erp-foundation"
POLICY="$ROOT/pm_ai/policy.yaml"
TMP="$ROOT/pm_ai/policy.auto.yaml"

RESP="$(curl -s "$SUPABASE_URL/rest/v1/v_policy_update_candidate" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY")"

echo "$RESP" | grep -q reason || exit 0

cp "$POLICY" "$TMP"

echo "" >> "$TMP"
echo "# auto-updated from ng_event" >> "$TMP"
echo "$RESP" | sed 's/"/''/g' >> "$TMP"

mv "$TMP" "$POLICY"
