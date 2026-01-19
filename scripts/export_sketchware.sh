OUT="$HOME/erp-foundation/exports/sketchware/export_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"

cp -r "$HOME/erp-foundation/app/src/main/res/layout" "$OUT/layout"
echo "OK: Sketchware export -> $OUT"
