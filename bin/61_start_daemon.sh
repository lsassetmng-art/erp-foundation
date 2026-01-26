#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"
PIDFILE="$ERP_HOME/run/pm_loop.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "already running: pid=$(cat "$PIDFILE")"
  exit 0
fi
nohup "$ERP_HOME/bin/60_pm_loop.sh" >/dev/null 2>&1 &
echo $! > "$PIDFILE"
echo "started: pid=$!"
