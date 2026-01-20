#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
DONE="$ROOT/pm_ai/done"
INBOX="$ROOT/pm_ai/inbox"
POLICY_NEXT="$ROOT/pm_ai/policy_next.yaml"

TASK="$(ls "$DONE"/* 2>/dev/null | tail -n 1)"
[ -f "$TASK" ] || exit 0

BASENAME="$(basename "$TASK")"
OUT="$INBOX/$BASENAME"

# --- AI修正プレースホルダ ---
# 今は機械的修正（後で GPT に差し替え）
sed '/TODO/d;/仮/d;/guess/d' "$TASK" > "$OUT"

exit 0
