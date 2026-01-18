#!/data/data/com.termux/files/usr/bin/bash
set -e

FILE="spec/usecases.schema.yaml"

echo "=== REVIEW USECASES ==="

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found"
  exit 1
fi

grep -E "company_id|SQL|HTTP" "$FILE" && {
  echo "ERROR: forbidden words detected"
  exit 1
}

echo "OK: usecases schema looks clean"
