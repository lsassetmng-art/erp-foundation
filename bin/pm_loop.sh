#!/data/data/com.termux/files/usr/bin/sh
set -eu

echo "▶ pm_loop start"

# repo root (cd非依存)
REPO="$(cd "$(dirname "$0")/.." && pwd)"
echo "▶ repo: $REPO"
cd "$REPO"

# clean check
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ working tree not clean; stop"
  echo
  echo "🔍 git status:"
  git status --short
  exit 10
fi

echo "✅ working tree clean"

INBOX="$REPO/pm_ai/inbox"
DONE="$REPO/pm_ai/done"
COUNT=0

mkdir -p "$INBOX" "$DONE"

for f in "$INBOX"/*.md; do
  [ -e "$f" ] || continue
  echo "▶ task: $(basename "$f")"

  # 今回は処理なし（将来実装）
  mv "$f" "$DONE/"
  COUNT=$((COUNT + 1))
done

if [ "$COUNT" -eq 0 ]; then
  echo "ℹ no tasks"
else
  echo "✅ processed $COUNT task(s)"
fi

echo "▶ pm_loop end"
exit 0
