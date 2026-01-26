#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

TITLE="${1:-}"
SQL_FILE="${2:-}"

if [ -z "$TITLE" ] || [ -z "$SQL_FILE" ] || [ ! -f "$SQL_FILE" ]; then
  echo "USAGE: $0 \"title\" /path/to/change.sql" >&2
  exit 2
fi

ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"
TMP="$ERP_HOME/tmp/enqueue.$$.$RANDOM.sql"

# NOTE: $$ を含むSQLファイルは壊れる可能性あり。必要なら $tag$ に切替する。
cat > "$TMP" <<SQL
SELECT governance.enqueue_policy_change(
  \$\$${TITLE}\$\$,
  \$\$$(cat "$SQL_FILE")\$\$
) AS change_id;
SQL

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$TMP"
rm -f "$TMP"
