#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="main"
LOG_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOG_DIR/auto_commit.log"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$LOG_DIR"

echo "---- $TIMESTAMP START ----" >> "$LOG_FILE"

# Git リポジトリ確認
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not a git repo" >> "$LOG_FILE"
  exit 1
fi

# ブランチ固定
CURRENT_BRANCH="$(git branch --show-current)"
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
  echo "ERROR: branch is $CURRENT_BRANCH (expected $BRANCH)" >> "$LOG_FILE"
  exit 1
fi

# 変更確認
if git diff --quiet && git diff --cached --quiet; then
  echo "No changes, exit" >> "$LOG_FILE"
  exit 0
fi

# add & commit
git add .

git commit -m "auto: update generated files ($TIMESTAMP)" >> "$LOG_FILE" 2>&1

# push（upstream 自動対応）
if ! git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
  git push -u origin "$BRANCH" >> "$LOG_FILE" 2>&1
else
  git push >> "$LOG_FILE" 2>&1
fi

echo "PUSH OK" >> "$LOG_FILE"
echo "---- END ----" >> "$LOG_FILE"
