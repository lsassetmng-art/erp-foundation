#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
: "${DATABASE_URL:?DATABASE_URL is required}"
SQL_TEXT="${1:-}"
[ -n "$SQL_TEXT" ] || { log_line NG "SQL empty"; exit 2; }
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
${SQL_TEXT}
SQL
