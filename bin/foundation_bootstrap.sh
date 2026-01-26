#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is not set}"

BASE_DIR="$HOME/erp-foundation"
INSTALL_SH="$BASE_DIR/bin/foundation_install.sh"
CHECK_SH="$BASE_DIR/bin/foundation_check.sh"

echo "== foundation_bootstrap =="

# -----------------------------------
# 0. 前提チェック
# -----------------------------------
if [ ! -x "$INSTALL_SH" ]; then
  echo "[bootstrap] ERROR: install script not found or not executable: $INSTALL_SH" >&2
  exit 1
fi

if [ ! -x "$CHECK_SH" ]; then
  echo "[bootstrap] ERROR: check script not found or not executable: $CHECK_SH" >&2
  exit 1
fi

# -----------------------------------
# 1. install
# -----------------------------------
echo "[bootstrap] step 1/2: foundation_install"
bash "$INSTALL_SH"

# -----------------------------------
# 2. check
# -----------------------------------
echo "[bootstrap] step 2/2: foundation_check"
bash "$CHECK_SH"

echo "== foundation_bootstrap: SUCCESS =="
