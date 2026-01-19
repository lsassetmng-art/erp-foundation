#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== AUTONOMOUS FLOW START ==="

python3 tools/generate_ui_state_mapper.py
python3 tools/generate_policy_next.py
bash scripts/flow_next_phase.sh

echo "=== AUTONOMOUS FLOW DONE ==="
