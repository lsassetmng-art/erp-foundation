#!/bin/sh
set -eu

REPO="$HOME/erp-foundation"
RULES="$REPO/pm_ai/rules"
TASK="${1:-}"

echo "▶ apply_task start"
echo "▶ repo: $REPO"

if [ ! -d "$RULES" ]; then
  echo "⚠ pm_ai/rules not found (rule-based control disabled)"
else
  echo "✔ rules detected"
fi

if [ -z "$TASK" ] || [ ! -f "$TASK" ]; then
  echo "❌ task file not found"
  exit 2
fi

echo "▶ task: $TASK"
echo "▶ applying task (business logic placeholder)"
echo "▶ apply_task end"
exit 0
