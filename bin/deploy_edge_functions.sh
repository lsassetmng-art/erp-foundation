#!/bin/sh
set -eu

BASE="$HOME/erp-foundation"
if ! command -v supabase >/dev/null 2>&1; then
  echo "WARN: supabase CLI not found (files created)."
  exit 2
fi

supabase functions deploy create-checkout
supabase functions deploy public-lp

echo "OK: deployed"
exit 0
