#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d-%H%M%S)"
OUT="exports/export-$TS"
mkdir -p "$OUT"

# AIDE向け（src & res）
mkdir -p "$OUT/aide/src" "$OUT/aide/res/layout" "$OUT/aide/docs"
cp -r app/src/main/java/app "$OUT/aide/src/" 2>/dev/null || true
cp -r app/src/main/java/foundation "$OUT/aide/src/" 2>/dev/null || true
cp -r app/src/main/res/layout/* "$OUT/aide/res/layout/" 2>/dev/null || true
cp -r docs/* "$OUT/aide/docs/" 2>/dev/null || true

# Sketchware向け（“素材”として同梱：直接インポートは環境差が大きいのでコピー前提）
mkdir -p "$OUT/sketchware/java" "$OUT/sketchware/layout" "$OUT/sketchware/docs"
cp -r "$OUT/aide/src/app" "$OUT/sketchware/java/" 2>/dev/null || true
cp -r "$OUT/aide/src/foundation" "$OUT/sketchware/java/" 2>/dev/null || true
cp -r "$OUT/aide/res/layout"/* "$OUT/sketchware/layout/" 2>/dev/null || true
cp -r "$OUT/aide/docs"/* "$OUT/sketchware/docs/" 2>/dev/null || true

cat << TXT > "$OUT/README.txt"
This export is a "copy-into-project" template.

AIDE:
- Copy:
  - aide/src/app and aide/src/foundation -> your project src/
  - aide/res/layout -> your project res/layout/
- Then build.

Sketchware:
- Direct import formats vary by version.
- Use this as source material:
  - sketchware/java -> add/merge Java classes
  - sketchware/layout -> copy XML layouts
TXT

echo "OK: exported to $OUT"
