#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
INBOX="$ROOT/pm_ai/inbox"
DONE="$ROOT/pm_ai/done"
LOG_DIR="$ROOT/logs"

TASK="$1"
NOW="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$DONE" "$LOG_DIR"

# ---- AI処理プレースホルダ ----
# ここに mother AI / GPT / rule engine を後で接続
# 今は「処理成功したこと」にする
# --------------------------------

BASENAME="$(basename "$TASK")"
mv "$TASK" "$DONE/$BASENAME"

echo "[$NOW] applied: $BASENAME" >> "$LOG_DIR/apply_task.log"

exit 0
