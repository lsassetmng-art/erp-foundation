#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

# refresh thresholds every loop is ok (it only updates when needed)
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "select governance.refresh_autonomy_thresholds(50);" >/dev/null
