#!/bin/sh
set -eu

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

TS="$(date +%Y%m%d-%H%M%S)"
OUT="$BASE/invoices/$TS"
mkdir -p "$OUT"

# ------------------------------------------------------------
# 1) 支払結果反映（Stripe/銀行 共通）
#    ※ 外部Webhookは別で受け、ここはDBを正とする
# ------------------------------------------------------------
PAID="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_payment_status?payment_status=eq.succeeded" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

if echo "$PAID" | grep -q "invoice_id"; then
  echo "$PAID" | sed -n 's/.*"invoice_id":"\([^"]*\)".*/\1/p' | while read IID; do
    curl -sS -X POST \
      "$SUPABASE_URL/rest/v1/rpc/mark_invoice_paid" \
      -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
      -H "Content-Type: application/json" \
      -d "{\"p_invoice_id\":\"$IID\"}" >/dev/null
  done
  EXIT=131
else
  EXIT=0
fi

# ------------------------------------------------------------
# 2) 請求PDF（HTML）生成
# ------------------------------------------------------------
INV="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_invoice_for_payment" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

if echo "$INV" | grep -q "invoice_id"; then
  echo "$INV" | while read LINE; do
    IID="$(echo "$LINE" | sed -n 's/.*"invoice_id":"\([^"]*\)".*/\1/p')"
    AMT="$(echo "$LINE" | sed -n 's/.*"amount_yen":\([0-9]*\).*/\1/p')"
    [ -z "$IID" ] && continue

    cat <<HTML > "$OUT/invoice_$IID.html"
<!doctype html><html><head><meta charset="utf-8">
<title>Invoice $IID</title></head>
<body>
<h1>Invoice</h1>
<p>Invoice ID: $IID</p>
<p>Amount: ¥$AMT</p>
<p>Date: $(date)</p>
<p>Status: Issued</p>
</body></html>
HTML
  done
  EXIT=132
fi

# ------------------------------------------------------------
# 3) 外販ランディング（価格表）
# ------------------------------------------------------------
PRICING="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.public_pricing" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

cat <<HTML > "$BASE/site/index.html"
<!doctype html><html><head><meta charset="utf-8">
<title>AI Approval SaaS</title></head>
<body>
<h1>AI Approval SaaS</h1>
<h2>Pricing</h2>
<pre>$PRICING</pre>
<p>Contact us to subscribe.</p>
</body></html>
HTML

exit "$EXIT"
