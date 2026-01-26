#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
INTERVAL_SEC="${INTERVAL_SEC:-60}"
log_line OK "pm_loop started"
while :; do
  "$(dirname "$0")/db_healthcheck.sh" || exit 20
  sleep "$INTERVAL_SEC"
done
