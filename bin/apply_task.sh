#!/bin/sh
set -eu

TASK_FILE="${1:-}"

echo "▶ apply_task start"
echo "▶ repo: $(git rev-parse --show-toplevel 2>/dev/null || echo unknown)"

# rules check
if [ ! -d "pm_ai/rules" ]; then
  echo "⚠ pm_ai/rules not found (rules-based control disabled)"
else
  echo "✔ rules detected"
fi

if [ -z "$TASK_FILE" ] || [ ! -f "$TASK_FILE" ]; then
  echo "❌ task file not found"
  exit 2
fi

echo "▶ task: $TASK_FILE"
echo "▶ applying task (business logic placeholder)"
echo "▶ apply_task end"
exit 0
