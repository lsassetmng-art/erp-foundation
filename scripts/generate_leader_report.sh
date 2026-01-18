#!/bin/bash
set -e

REPORT_DIR="reports"
REPORT="$REPORT_DIR/leader_report.md"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

mkdir -p "$REPORT_DIR"

cat << EOF > "$REPORT"
# 🚨 SAFE STOP REPORT

generated_at: $DATE

## Trigger
- spec/usecases.schema.yaml changed

## Decision
- Auto generation stopped
- Manual approval required

## Required Actions
1. Review spec diff
2. Confirm domain intent
3. Approve regeneration

EOF

echo "📝 Leader report generated"
