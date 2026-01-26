#!/bin/sh
set -eu

# 必須環境変数
: "${AUDIT_RUN_ID:?missing}"
: "${AUDIT_ENVIRONMENT:?missing}"
: "${AUDIT_SOURCE:?missing}"
: "${SUPABASE_URL:?missing}"
: "${SUPABASE_SERVICE_ROLE_KEY:?missing}"

STARTED_AT="$(date -Is)"

payload_start=$(cat <<JSON
{
  "run_id": "$AUDIT_RUN_ID",
  "started_at": "$STARTED_AT",
  "environment": "$AUDIT_ENVIRONMENT",
  "source": "$AUDIT_SOURCE",
  "status": "running"
}
JSON
)

curl -sSf \
  -X POST "$SUPABASE_URL/rest/v1/audit_run_summary" \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d "$payload_start" >/dev/null

echo "▶ audit run started: $AUDIT_RUN_ID"

exit 0
