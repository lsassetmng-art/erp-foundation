#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"

"$ERP_HOME/ai/mother.sh"
echo "OK: phase1-3 pipeline done"
exit 0
