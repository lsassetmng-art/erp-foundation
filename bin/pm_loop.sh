#!/bin/sh
set -eu

# ============================================================
# pm_loop.sh
# Project Manager main loop (Termux edition)
# ============================================================

ROOT="$HOME/erp-foundation"
BIN="$ROOT/bin"
LOG_DIR="$ROOT/logs"
INBOX="$ROOT/pm_ai/inbox"

mkdir -p "$LOG_DIR"

NOW="$(date '+%Y-%m-%d %H:%M:%S')"

echo "▶ pm_loop start"
echo "▶ repo: $ROOT"

# ------------------------------------------------------------
# 0. Git working tree guard
# ------------------------------------------------------------
if command -v git >/dev/null 2>&1; then
  if [ "${PM_ALLOW_DIRTY:-0}" != "1" ]; then
    if [ -n "$(git -C "$ROOT" status --porcelain 2>/dev/null)" ]; then
      echo "❌ working tree not clean; stop"
      git -C "$ROOT" status --short || true
      echo "[$NOW] ❌ pm_loop FAILED (dirty tree)" > "$LOG_DIR/pm_loop.status"
      echo "PM LOOP FAILED at $NOW (dirty tree)" > "$LOG_DIR/pm_loop.notify"
      exit 4
    fi
  fi
fi

# ------------------------------------------------------------
# 1. lint phase
# ------------------------------------------------------------
if [ ! -x "$BIN/pm_lint.sh" ]; then
  echo "❌ pm_lint.sh not found"
  echo "[$NOW] ❌ pm_loop FAILED (lint missing)" > "$LOG_DIR/pm_loop.status"
  echo "PM LOOP FAILED at $NOW (lint missing)" > "$LOG_DIR/pm_loop.notify"
  exit 4
fi

"$BIN/pm_lint.sh"

# ------------------------------------------------------------
# 2. apply_task phase
# ------------------------------------------------------------
TASK_COUNT=0

if [ -d "$INBOX" ]; then
  for TASK in "$INBOX"/*; do
    [ -f "$TASK" ] || continue
    TASK_COUNT=$((TASK_COUNT + 1))

    echo "▶ task: $TASK"

    if [ -x "$BIN/apply_task.sh" ]; then
      "$BIN/apply_task.sh" "$TASK"
    else
      echo "▶ applying task (business logic placeholder)"
    fi
  done
fi

echo "✔ processed $TASK_COUNT task(s)"
echo "▶ pm_loop end"

# ------------------------------------------------------------
# 3. status / notify (EXIT CODE AWARE)
# ------------------------------------------------------------
EXIT_CODE=0
NOW="$(date '+%Y-%m-%d %H:%M:%S')"

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "[$NOW] ✅ pm_loop SUCCESS" > "$LOG_DIR/pm_loop.status"
  echo "PM LOOP SUCCESS at $NOW" > "$LOG_DIR/pm_loop.notify"
else
  echo "[$NOW] ❌ pm_loop FAILED (exit=$EXIT_CODE)" > "$LOG_DIR/pm_loop.status"
  echo "PM LOOP FAILED at $NOW (exit=$EXIT_CODE)" > "$LOG_DIR/pm_loop.notify"
fi

echo "$NOW" > "$LOG_DIR/pm_loop.last"

exit "$EXIT_CODE"
