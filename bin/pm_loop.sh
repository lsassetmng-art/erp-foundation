#!/bin/sh
set -e

BASE="$HOME/erp-foundation"
BIN="$BASE/bin"
PM="$BASE/pm_ai"
INBOX="$PM/inbox"
DONE="$PM/done"
LOGS="$BASE/logs"
RUNLOG="$LOGS/pm_loop.log"

mkdir -p "$INBOX" "$DONE" "$LOGS"

# load optional env (for future extensions)
sh "$BIN/_load_env.sh" || true

# choose oldest task
task="$(ls -1 "$INBOX"/*.md 2>/dev/null | head -n 1 || true)"
[ -n "$task" ] || { echo "ℹ️ no tasks"; exit 0; }

task_base="$(basename "$task" .md)"
branch="ai/${task_base}"

echo "=== $(date) START $task_base ===" >>"$RUNLOG"

cd "$BASE"

# ensure clean baseline (non-destructive)
if git status --porcelain | grep . >/dev/null 2>&1; then
  echo "❌ working tree not clean; stop" | tee -a "$RUNLOG"
  exit 1
fi

# make sure main exists locally
git checkout main >/dev/null 2>&1 || git checkout -b main >/dev/null 2>&1

# create branch (idempotent)
if git show-ref --verify --quiet "refs/heads/$branch"; then
  git checkout "$branch" >/dev/null 2>&1
else
  git checkout -b "$branch" >/dev/null 2>&1
fi

# if patch exists, apply it
patch1="$INBOX/${task_base}.patch"
patch2="$INBOX/${task_base}.diff"

if [ -f "$patch1" ]; then
  sh "$BIN/impl_apply_patch.sh" "$patch1" | tee -a "$RUNLOG"
elif [ -f "$patch2" ]; then
  sh "$BIN/impl_apply_patch.sh" "$patch2" | tee -a "$RUNLOG"
else
  echo "ℹ️ no patch for $task_base (instruction-only)" | tee -a "$RUNLOG"
fi

# record instruction snapshot into logs (non-destructive)
cp -f "$task" "$LOGS/${task_base}.md" 2>/dev/null || true

# run safe git runner (commit/push)
# note: git_runner.sh commits/pushes current branch
if sh "$BIN/git_runner.sh"; then
  echo "✅ runner ok" | tee -a "$RUNLOG"
else
  rc="$?"
  echo "❌ runner failed rc=$rc" | tee -a "$RUNLOG"
  exit 1
fi

# move to done
mv "$task" "$DONE/${task_base}.md"
[ -f "$patch1" ] && mv "$patch1" "$DONE/${task_base}.patch" || true
[ -f "$patch2" ] && mv "$patch2" "$DONE/${task_base}.diff" || true

echo "=== $(date) DONE  $task_base ===" >>"$RUNLOG"
exit 0
