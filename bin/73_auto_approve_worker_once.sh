#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

# auto approve up to N per loop (default 3)
N="${1:-3}"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -tA -c "select governance.auto_approve_and_enqueue($N);" >/dev/null
