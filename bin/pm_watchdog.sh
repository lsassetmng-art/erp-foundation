#!/data/data/com.termux/files/usr/bin/sh
set -eu

PM="${HOME}/erp-foundation/bin/pm_loop_ch.sh"
LOG="${HOME}/erp-foundation/logs/watchdog.log"

while :; do
  if pgrep -f "pm_loop_ch.sh" >/dev/null 2>&1; then
    sleep 30
  else
    echo "$(date -u) restart pm_loop" >>"$LOG"
    nohup "$PM" >>"$LOG" 2>&1 &
    sleep 10
  fi
done
