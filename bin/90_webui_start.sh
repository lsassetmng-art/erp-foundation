#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"
PORT="${GOV_UI_PORT:-8765}"
cd "$ERP_HOME/web"
echo "Open: http://127.0.0.1:${PORT}/"
python -m http.server "$PORT"
