#!/data/data/com.termux/files/usr/bin/bash
set -e
SPEC="spec/usecases.schema.yaml"
echo "[REVIEW] Checking $SPEC"

grep -E "company_id|user_id|sql|sqlite|supabase|http|https|table|ddl" "$SPEC" \
  && { echo "NG: forbidden token found"; exit 1; } || true

grep -E "name:\s+[a-z]" "$SPEC" \
  && { echo "NG: usecase name must be PascalCase"; exit 1; } || true

echo "OK: review passed"
