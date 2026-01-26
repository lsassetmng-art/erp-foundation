#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"
python3 "$ERP_HOME/ai/mother.py"
