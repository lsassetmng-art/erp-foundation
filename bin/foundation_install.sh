#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is not set}"

BASE_DIR="$HOME/erp-foundation"
DDL_FILE="$BASE_DIR/ddl/foundation.sql"

if [ ! -f "$DDL_FILE" ]; then
  echo "[foundation_install] ERROR: DDL not found: $DDL_FILE" >&2
  exit 1
fi

echo "[foundation_install] applying DDL via DATABASE_URL ..."
psql "$DATABASE_URL" -f "$DDL_FILE"
echo "[foundation_install] OK"
