#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d-%H%M%S)"
OUT="exports/export-$TS"

mkdir -p "$OUT/java" "$OUT/res/layout" "$OUT/docs"

# Java（生成物中心）
cp -r app/src/main/java/app "$OUT/java/" 2>/dev/null || true
cp -r app/src/main/java/foundation "$OUT/java/" 2>/dev/null || true

# XML
cp -r app/src/main/res/layout/* "$OUT/res/layout/" 2>/dev/null || true

# Docs
cp -r docs/* "$OUT/docs/" 2>/dev/null || true

echo "OK: exported to $OUT"
echo "Tip: AIDEなら OUT/java をプロジェクトの src にコピー"
echo "Tip: Sketchwareは直接importが難しいので OUT をPCへ転送して適用"
