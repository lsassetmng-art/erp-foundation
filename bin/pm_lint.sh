#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
LOG_DIR="$ROOT/logs"
INBOX="$ROOT/pm_ai/inbox"

mkdir -p "$LOG_DIR"
NOW="$(date '+%Y-%m-%d %H:%M:%S')"

NG_REASON=""

# inbox が無い or 空
if [ ! -d "$INBOX" ] || ! ls "$INBOX"/* >/dev/null 2>&1; then
  NG_REASON="no task in inbox"
fi

# 内容チェック
if [ -z "$NG_REASON" ]; then
  for F in "$INBOX"/*; do
    [ -f "$F" ] || continue
    if [ ! -s "$F" ]; then
      NG_REASON="empty task: $(basename "$F")"
      break
    fi
    if grep -qiE 'TODO|仮|guess' "$F"; then
      NG_REASON="forbidden word in $(basename "$F")"
      break
    fi
  done
fi

if [ -n "$NG_REASON" ]; then
  echo "[$NOW] NG: $NG_REASON" > "$LOG_DIR/pm_lint.last"
  exit 4
fi

echo "[$NOW] OK" > "$LOG_DIR/pm_lint.last"
exit 0
