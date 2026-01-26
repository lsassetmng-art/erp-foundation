#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SQL_FILE="${1:-}"
if [ -z "$SQL_FILE" ] || [ ! -f "$SQL_FILE" ]; then
  echo "Usage: psql_run.sh path/to.sql" >&2
  exit 2
fi
: "${DATABASE_URL:?DATABASE_URL is required}"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$SQL_FILE"
