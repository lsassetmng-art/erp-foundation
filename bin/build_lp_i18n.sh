#!/bin/sh
set -eu

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"
OUTDIR="$HOME/erp-foundation/site"
mkdir -p "$OUTDIR"

render () {
  LANG="$1"
  TITLE="$(curl -s "$SUPABASE_URL/rest/v1/approval.public_i18n?lang=eq.$LANG&key=eq.lp_title&select=value&limit=1" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" | sed -n 's/.*"value":"\([^"]*\)".*/\1/p')"
  SUB="$(curl -s "$SUPABASE_URL/rest/v1/approval.public_i18n?lang=eq.$LANG&key=eq.lp_subtitle&select=value&limit=1" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" | sed -n 's/.*"value":"\([^"]*\)".*/\1/p')"
  PRICING_LABEL="$(curl -s "$SUPABASE_URL/rest/v1/approval.public_i18n?lang=eq.$LANG&key=eq.pricing&select=value&limit=1" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" | sed -n 's/.*"value":"\([^"]*\)".*/\1/p')"

  PRICING="$(curl -s "$SUPABASE_URL/rest/v1/approval.public_pricing" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

  cat <<HTML > "$OUTDIR/index_${LANG}.html"
<!doctype html><html><head><meta charset="utf-8"><title>${TITLE}</title></head>
<body>
<h1>${TITLE}</h1>
<p>${SUB}</p>
<h2>${PRICING_LABEL}</h2>
<pre>${PRICING}</pre>
</body></html>
HTML
}

render ja
render en

echo "OK: $OUTDIR/index_ja.html and index_en.html"
exit 0
