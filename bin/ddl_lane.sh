#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
: "${DATABASE_URL_DDL:?DATABASE_URL_DDL is required}"
SQL_FILE="${1:-}"
[ -f "$SQL_FILE" ] || { log_line NG "SQL file not found"; exit 2; }
psql "$DATABASE_URL_DDL" -v ON_ERROR_STOP=1 <<'SQL'
select inet_server_port(), current_setting('ssl');
SQL
psql "$DATABASE_URL_DDL" -v ON_ERROR_STOP=1 -f "$SQL_FILE"
