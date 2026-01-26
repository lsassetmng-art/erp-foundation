#!/bin/sh
set -eu

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

TS="$(date +%Y%m%d-%H%M%S)"
OUTDIR="$HOME/erp-foundation/reports/$TS"
mkdir -p "$OUTDIR"

fetch_csv () {
  VIEW="$1"
  OUT="$2"
  curl -sS "$SUPABASE_URL/rest/v1/$VIEW?select=*" \
    -H "apikey: $KEY" \
    -H "Authorization: Bearer $KEY" \
    -H "Accept: text/csv" > "$OUT"
}

# 1) 監査レポート CSV
fetch_csv "approval.v_audit_report_export" "$OUTDIR/audit_override_report.csv"

# 2) ROI レポート CSV
fetch_csv "approval.v_roi_report_export" "$OUTDIR/roi_monthly_report.csv"

# 3) J-SOX 統制マトリクス CSV
fetch_csv "approval.v_jsox_control_matrix" "$OUTDIR/jsox_control_matrix.csv"

# 4) PDF 代替：HTML（ブラウザ印刷でPDF化）
to_html () {
  CSV="$1"
  HTML="$2"
  {
    echo "<!doctype html><html><head><meta charset='utf-8'><title>Report</title></head><body>"
    echo "<h2>$(basename "$CSV")</h2>"
    echo "<pre style='white-space:pre-wrap;font-family:monospace'>"
    cat "$CSV"
    echo "</pre></body></html>"
  } > "$HTML"
}

to_html "$OUTDIR/audit_override_report.csv" "$OUTDIR/audit_override_report.html"
to_html "$OUTDIR/roi_monthly_report.csv"   "$OUTDIR/roi_monthly_report.html"
to_html "$OUTDIR/jsox_control_matrix.csv"  "$OUTDIR/jsox_control_matrix.html"

# 5) 可能なら自動PDF（python+reportlab が既にある場合のみ）
if command -v python >/dev/null 2>&1; then
  python - <<PY 2>/dev/null || true
import os, sys
outdir = os.environ.get("OUTDIR","")
try:
    from reportlab.lib.pagesizes import A4
    from reportlab.pdfgen import canvas
except Exception:
    sys.exit(0)

def csv_to_pdf(csv_path, pdf_path, title):
    c = canvas.Canvas(pdf_path, pagesize=A4)
    w,h = A4
    y = h - 40
    c.setFont("Helvetica-Bold", 14)
    c.drawString(40, y, title)
    y -= 24
    c.setFont("Helvetica", 9)
    with open(csv_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            if y < 40:
                c.showPage()
                y = h - 40
                c.setFont("Helvetica", 9)
            c.drawString(40, y, line.strip()[:120])
            y -= 12
    c.save()

base = outdir
csv_to_pdf(os.path.join(base,"audit_override_report.csv"), os.path.join(base,"audit_override_report.pdf"), "Audit Override Report")
csv_to_pdf(os.path.join(base,"roi_monthly_report.csv"), os.path.join(base,"roi_monthly_report.pdf"), "Monthly ROI Report")
csv_to_pdf(os.path.join(base,"jsox_control_matrix.csv"), os.path.join(base,"jsox_control_matrix.pdf"), "J-SOX Control Matrix")
PY
fi

echo "OK: exported to $OUTDIR"
exit 0
