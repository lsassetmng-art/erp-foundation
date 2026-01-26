#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"
REASON="${1:-manual freeze}"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
INSERT INTO governance.freeze_state(enabled, reason) VALUES (true, \$\$${REASON}\$\$);
SQL
echo "OK: frozen"
