#!/bin/bash
set -e

SPEC="spec/usecases.schema.yaml"
HASH_FILE="spec/.hash"
REPORT="reports/spec_diff_summary.md"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

[ ! -f "$SPEC" ] && exit 0
[ ! -f "$HASH_FILE" ] && exit 0

OLD_HASH=$(cat "$HASH_FILE")

# git diff を使う（hash更新前提）
DIFF=$(git diff -- "$SPEC" || true)

ADD=$(echo "$DIFF" | grep '^+' | grep -v '^+++' | wc -l)
DEL=$(echo "$DIFF" | grep '^-' | grep -v '^---' | wc -l)

cat << EOF > "$REPORT"
# 📄 SPEC DIFF SUMMARY

generated_at: $DATE

## Target
- file: spec/usecases.schema.yaml

## Change summary
- added_lines: $ADD
- removed_lines: $DEL

## Raw diff (excerpt)
\`\`\`diff
$(echo "$DIFF" | head -n 200)
\`\`\`

## Reviewer assessment
- Potential breaking change: $([ "$DEL" -gt 0 ] && echo "YES" || echo "UNKNOWN")
- Manual review required: YES

EOF

echo "🧾 spec diff summary generated"
