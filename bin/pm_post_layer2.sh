#!/bin/sh
set -e

SUMMARY="$1"

ORDER_ID=$(echo "$SUMMARY" | sed -n 's/.*order_id=\([^ ]*\).*/\1/p')
SEVERITY=$(echo "$SUMMARY" | sed -n 's/.*severity=\([^ ]*\).*/\1/p')

REQ_ID=$(curl -s \
 "$SUPABASE_URL/rest/v1/approval_request?order_id=eq.$ORDER_ID&status=eq.pending&select=request_id&limit=1" \
 -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
 -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
 | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p' || true)

if [ -n "$REQ_ID" ]; then
  echo "Approval required: https://YOUR-DOMAIN/approval.html?request_id=$REQ_ID"
  exit 10
fi

exit 0
