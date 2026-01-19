#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PM_AI="$ROOT/pm_ai"
INBOX="$PM_AI/inbox"
DONE="$PM_AI/done"
RULES="$PM_AI/rules"

echo "▶ pm_loop start"
echo "▶ repo: $ROOT"

# git clean gate
if ! git -C "$ROOT" diff --quiet; then
  echo "❌ working tree not clean; stop"
  git -C "$ROOT" status --short
  exit 1
fi

# rules must exist
if [ ! -d "$RULES" ] || [ -z "$(ls -A "$RULES" 2>/dev/null)" ]; then
  echo "❌ PM rules not found or empty: $RULES"
  exit 3
fi

processed=0
for task in "$INBOX"/*.md; do
  [ -f "$task" ] || continue
  name="$(basename "$task")"
  echo "▶ task: $name"

  # 対象業務抽出（erp-xxx）
  targets="$(grep -Eo 'erp-[a-z]+' "$task" | sort -u | tr '\n' ' ')"
  if [ -z "$targets" ]; then
    echo "⚠ no target business found; skip"
    mv "$task" "$DONE/$name"
    continue
  fi

  rc_all=0
  for t in $targets; do
    repo="$HOME/$t"
    apply="$repo/apply_task.sh"
    echo "➡ call: $t"

    if [ ! -x "$apply" ]; then
      echo "❌ apply_task.sh not found: $apply"
      rc_all=2
      continue
    fi

    if ! "$apply" "$task"; then
      echo "❌ apply failed: $t"
      rc_all=2
    fi
  done

  # 処理済みに移動（再実行防止）
  mv "$task" "$DONE/$name"
  processed=$((processed+1))

  # どれか失敗したら exit 非0（CI連動）
  if [ "$rc_all" -ne 0 ]; then
    echo "❌ task failed: $name"
    exit 2
  fi
done

echo "✔ processed $processed task(s)"
echo "▶ pm_loop end"
exit 0
