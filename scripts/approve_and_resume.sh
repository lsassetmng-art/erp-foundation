#!/bin/bash
set -e

SPEC="spec/usecases.schema.yaml"
HASH_FILE="spec/.hash"
STOP_FLAG="scripts/safe_stop.flag"

[ ! -f "$SPEC" ] && exit 1

echo "✔ Approving current spec and resuming automation"

rm -f "$STOP_FLAG"
sha256sum "$SPEC" | awk '{print $1}' > "$HASH_FILE"

# 再生成
./scripts/full_generate.sh
