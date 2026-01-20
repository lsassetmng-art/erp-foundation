#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
BIN="$ROOT/bin"

# lint NG の場合のみ実行される想定
"$BIN/gen_policy_next.sh" || true
"$BIN/analyze_ng.sh" || true
"$BIN/ai_rewrite_task.sh" || true

exit 0
