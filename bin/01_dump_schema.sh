#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"
: "${DATABASE_URL:?NG: DATABASE_URL not set}"

OUTDIR="$ERP_HOME/ddl/official"
mkdir -p "$OUTDIR"

TS="$(date +%Y%m%d_%H%M%S)"
RAW="$OUTDIR/schema_raw_${TS}.sql"
NORM="$OUTDIR/official_ddl_${TS}.sql"
LATEST="$OUTDIR/official_ddl.sql"

# dump schema (connect/disconnect included by psql)
# -X: no .psqlrc, -v ON_ERROR_STOP: strict, -q: quiet
psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 -q <<SQL > "$RAW"
\set ON_ERROR_STOP on
\pset pager off
-- schema-only dump (pg_catalog query approach)
-- We rely on pg_dump existing? Not guaranteed in Termux.
-- So: use pg_dump if available, else fallback to information schema isn't enough for full DDL.
SQL

# If pg_dump exists, prefer it (full fidelity)
if command -v pg_dump >/dev/null 2>&1; then
  pg_dump "$DATABASE_URL" --schema-only --no-owner --no-privileges > "$RAW"
else
  echo "NG: pg_dump not found. Install postgresql package that includes pg_dump, or provide schema dump another way." >&2
  echo "HINT: pkg install postgresql" >&2
  exit 91
fi

# Normalize line endings
tr -d '\r' < "$RAW" > "$NORM"

# Update LATEST pointer
cp -f "$NORM" "$LATEST"

echo "OK: dumped"
echo "RAW   : $RAW"
echo "NORM  : $NORM"
echo "LATEST: $LATEST"
exit 0
