#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"
: "${DATABASE_URL:?NG: DATABASE_URL not set}"

OUTDIR="$ERP_HOME/reports"
mkdir -p "$OUTDIR"
OUT="$OUTDIR/missing_company_id.txt"
OUT_APP="$OUTDIR/missing_company_id_app_only.txt"

# Define "business schemas that MUST have company_id"
# (adjust if you add/remove app schemas)
APP_SCHEMAS_REGEX='^(sales|purchase|billing|inventory|manufacturing|hr|ops|approval|audit|governance|compliance|integration|analytics|ci|media|core)\.'

# Extract tables that do NOT have company_id
# connect/disconnect included
psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 -q -c "
WITH tbl AS (
  SELECT table_schema, table_name
  FROM information_schema.tables
  WHERE table_type='BASE TABLE'
    AND table_schema NOT IN ('pg_catalog','information_schema')
),
cols AS (
  SELECT table_schema, table_name,
         max((column_name='company_id')::int) AS has_company_id
  FROM information_schema.columns
  WHERE table_schema NOT IN ('pg_catalog','information_schema')
  GROUP BY 1,2
)
SELECT
  'MISSING company_id: '||t.table_schema||'.'||t.table_name AS line
FROM tbl t
JOIN cols c USING (table_schema, table_name)
WHERE c.has_company_id=0
ORDER BY 1;
" | sed '/^$/d' > "$OUT"

# Filter only app schemas (must be empty for Phase1 pass)
grep -E "MISSING company_id: ${APP_SCHEMAS_REGEX}" "$OUT" > "$OUT_APP" || true

if [ -s "$OUT_APP" ]; then
  echo "NG: company_id missing in APP schemas:"
  cat "$OUT_APP"
  exit 21
fi

echo "OK: app schemas all have company_id (non-app may be missing and that is allowed)"
echo "report: $OUT"
exit 0
