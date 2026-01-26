#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"

PM="${HOME}/erp-foundation/bin/pm_loop.sh"
LOGF="${HOME}/erp-foundation/logs/watchdog.log"

while :; do
  if pgrep -f "erp-foundation/bin/pm_loop.sh" >/dev/null 2>&1; then
    sleep 20
  else
    log WARN "pm_loop not running -> restart"
    nohup "$PM" >>"$LOGF" 2>&1 &
    sleep 3
  fi
done
