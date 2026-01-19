#!/data/data/com.termux/files/usr/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "▶ pm_loop start"
echo "▶ repo: $ROOT_DIR"

# --- git 管理チェック ---
if ! command -v git >/dev/null 2>&1; then
  echo "❌ git not found"
  exit 127
fi

# --- working tree clean チェック ---
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ working tree not clean; stop"
  echo ""
  echo "🔍 git status:"
  git status --short
  echo ""
  echo "💡 hint:"
  echo "  - commit する"
  echo "  - または .gitignore に追加する"
  exit 10
fi

echo "✅ working tree clean"

# --- inbox 処理 ---
INBOX="$ROOT_DIR/pm_ai/inbox"
DONE="$ROOT_DIR/pm_ai/done"
mkdir -p "$DONE"

count=0
for f in "$INBOX"/*.md 2>/dev/null; do
  [ -f "$f" ] || continue
  count=$((count+1))
  echo "▶ apply task: $(basename "$f")"
  sh "$ROOT_DIR/bin/impl_apply_patch.sh" "$f"
  mv "$f" "$DONE/"
done

if [ "$count" -eq 0 ]; then
  echo "ℹ no tasks"
else
  echo "✅ processed $count task(s)"
fi

echo "▶ pm_loop end"
exit 0
