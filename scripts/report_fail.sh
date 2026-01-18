#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
REPORT="reports/fail_${TS}.md"

cat << RPT > "$REPORT"
# ❌ Full Generate Failure Report

- time: $TS
- cwd: $ROOT_DIR
- git-branch: $(git branch --show-current)

## Git Status
\`\`\`
$(git status --short)
\`\`\`
RPT

echo "[REPORT] $REPORT created"
