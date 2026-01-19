#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== FOUNDATION STAGE 1-3 START ==="

echo "[1/3] Generate validation schema"
python3 tools/generate_validation_schema.py

echo "[2/3] Apply validation to ViewModels"
python3 tools/apply_validation_to_viewmodels.py

echo "[3/3] Wire Fragment field errors (safe, no material dependency)"
python3 tools/wire_fragment_field_errors.py

echo "=== FOUNDATION STAGE 1-3 DONE ==="
