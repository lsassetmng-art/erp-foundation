#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[ROLLBACK] reset working tree"
git reset --hard HEAD || true
git clean -fd || true
echo "[ROLLBACK] done"
