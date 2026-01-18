#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

SPEC="spec/usecases.schema.yaml"

if [ ! -f "$SPEC" ]; then
  echo "ERROR: spec not found"
  exit 1
fi

if grep -E "company_id|table|sql|http" "$SPEC" >/dev/null; then
  echo "ERROR: forbidden keyword detected in spec"
  exit 1
fi

echo "OK: usecases schema looks clean"
