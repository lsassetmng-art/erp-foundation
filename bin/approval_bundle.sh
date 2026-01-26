#!/bin/sh
set -eu

FOUND="$HOME/erp-foundation"
BIN="$FOUND/bin"
UI="$FOUND/ui"
mkdir -p "$BIN" "$UI"

# ============================================================
# pm_post_layer2.sh
# ============================================================
cat <<'SH' > "$BIN/pm_post_layer2.sh"
#!/bin/sh
set -eu

LINE="${1:-}"

policies=$(echo "$LINE" | sed -n 's/.*policies=\([0-9][0-9]*\).*/\1/p')
ext=$(echo "$LINE" | sed -n 's/.*sales_external_impact_true=\([0-9][0-9]*\).*/\1/p')
policies=${policies:-0}
ext=${ext:-0}

COMPANY_ID="${COMPANY_ID:-}"
ORDER_ID="${ORDER_ID:-}"
ORDER_NO="${ORDER_NO:-}"

if [ "$policies" -gt 0 ] || [ "$ext" -gt 0 ]; then
  if [ -z "$COMPANY_ID" ] || [ -z "$ORDER_ID" ] || [ -z "$ORDER_NO" ]; then
    echo "Approval REQUIRED but missing params"
    exit 11
  fi

  curl -sS -X POST "$SUPABASE_URL/rest/v1/rpc/request_order_approval_safe" \
    -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"p_company_id\":\"$COMPANY_ID\",
      \"p_order_id\":$ORDER_ID,
      \"p_order_no\":\"$ORDER_NO\",
      \"p_policy_id\":\"p_sales_external_impact\",
      \"p_reason\":\"external_impact\"
    }" >/dev/null

  echo "[SLACK] Approval REQUIRED"
  echo "[LINE]  Approval REQUIRED"
  exit 10
fi

echo "[SLACK] Approval PASSED"
echo "[LINE]  Approval PASSED"
exit 0
SH
chmod +x "$BIN/pm_post_layer2.sh"

# ============================================================
# approval.html（Web / Android 共通）
# ============================================================
cat <<'HTML' > "$UI/approval.html"
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Approval</title></head>
<body>
<h2>Pending Approval</h2>
<table border="1">
<thead><tr><th>Order</th><th>Reason</th><th>At</th><th>Action</th></tr></thead>
<tbody id="t"></tbody>
</table>

<script>
const url = new URLSearchParams(location.search).get("url");
const key = new URLSearchParams(location.search).get("key");

fetch(`${url}/rest/v1/approval.v_pending_approval_ui`,{
 headers:{apikey:key,Authorization:`Bearer ${key}`}
})
.then(r=>r.json()).then(rows=>{
 const tb=document.getElementById("t");
 rows.forEach(r=>{
  const tr=document.createElement("tr");
  tr.innerHTML=
   `<td>${r.order_no}</td><td>${r.reason}</td><td>${r.detected_at}</td>
    <td>
     <button onclick="act('approve', '${r.request_id}')">Approve</button>
     <button onclick="act('reject', '${r.request_id}')">Reject</button>
    </td>`;
  tb.appendChild(tr);
 });
});

function act(a,id){
 fetch(`${url}/rest/v1/rpc/${a}_request`,{
  method:"POST",
  headers:{apikey:key,Authorization:`Bearer ${key}`,'Content-Type':'application/json'},
  body:JSON.stringify({p_request_id:id,p_actor:"00000000-0000-0000-0000-000000000000",p_note:null})
 }).then(()=>location.reload());
}
</script>
</body>
</html>
HTML

echo "approval bundle installed"
