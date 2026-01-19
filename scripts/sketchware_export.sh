#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BASE_DIR"

OUT="$BASE_DIR/exports/sketchware/export_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"/{layout,java,values}

# layout -> Sketchware layout
cp -r app/src/main/res/layout/* "$OUT/layout/" 2>/dev/null || true
cp -r app/src/main/res/values/* "$OUT/values/" 2>/dev/null || true

# Java(Fragments/ViewModels only) -> Sketchware java folder
mkdir -p "$OUT/java/app/ui"
cp -r app/src/main/java/app/ui/* "$OUT/java/app/ui/" 2>/dev/null || true

echo "OK: Sketchware export created: $OUT"
