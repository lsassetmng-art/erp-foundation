#!/bin/sh
set -eu

# 必須
: "${AUDIT_RUN_ID:?missing}"
: "${AUDIT_STATUS:?missing}"

MSG="[AUDIT] run=$AUDIT_RUN_ID status=$AUDIT_STATUS"

# Stub（本番では webhook に差替え）
echo "$MSG"

exit 0
