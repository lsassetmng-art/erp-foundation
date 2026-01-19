#!/bin/sh
set -eu

LOG_DIR="$HOME/erp-foundation/logs"

mkdir -p "$LOG_DIR"

NOW="$(date '+%Y-%m-%d %H:%M:%S')"

echo "[$NOW] pm_lint OK (dummy)" > "$LOG_DIR/pm_lint.last"

exit 0
