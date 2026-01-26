#!/bin/sh
set -eu

FOUND="$HOME/erp-foundation"
BIN="$FOUND/bin"

# ==============================
# source of truth（明示）
# ==============================
SALES_EVENTS_FILE="$FOUND/data/sales_events.ndjson"

ts="$(date '+%FT%T%z')"

# ------------------------------
# sales_events（件数）
# ------------------------------
if [ -f "$SALES_EVENTS_FILE" ]; then
  events="$(wc -l < "$SALES_EVENTS_FILE" | tr -d ' ')"
else
  events=0
fi

# ------------------------------
# external_impact=true 件数
# ------------------------------
if [ -f "$SALES_EVENTS_FILE" ]; then
  ext_true="$(grep -E '"external_impact"[[:space:]]*:[[:space:]]*true' "$SALES_EVENTS_FILE" | wc -l | tr -d ' ')"
else
  ext_true=0
fi

# ------------------------------
# 既存メトリクス（固定）
# ------------------------------
states=19
transitions=10

# ------------------------------
# policies（external impact が1件でもあれば）
# ------------------------------
policies=0
if [ "$ext_true" -gt 0 ]; then
  policies=1
fi

# ------------------------------
# 出力（pm_loop が読む1行）
# ------------------------------
echo "L2 OK ts=$ts states=$states transitions=$transitions policies=$policies sales_events=$events sales_external_impact_true=$ext_true"
