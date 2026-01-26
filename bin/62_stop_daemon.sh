#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"
PIDFILE="$ERP_HOME/run/pm_loop.pid"
if [ ! -f "$PIDFILE" ]; then
  echo "not running"
  exit 0
fi
PID="$(cat "$PIDFILE")"
if kill -0 "$PID" 2>/dev/null; then kill "$PID" || true; fi
rm -f "$PIDFILE"
echo "stopped"
