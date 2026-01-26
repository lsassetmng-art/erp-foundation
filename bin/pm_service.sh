#!/data/data/com.termux/files/usr/bin/sh
set -eu
BASE_DIR="${HOME}/erp-foundation"
BIN_DIR="${BASE_DIR}/bin"
CFG_DIR="${BASE_DIR}/conf"
LOG_DIR="${BASE_DIR}/logs"
PID_FILE="${BASE_DIR}/pm_loop.pid"
mkdir -p "$LOG_DIR"

cmd="${1:-}"
case "$cmd" in
  start)
    [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null && { echo "already running pid=$(cat "$PID_FILE")"; exit 0; } || true
    # shellcheck disable=SC1090
    . "${CFG_DIR}/db.env"
    nohup "${BIN_DIR}/pm_loop_ch.sh" >> "${LOG_DIR}/pm_loop.log" 2>&1 &
    echo $! > "$PID_FILE"
    echo "started pid=$(cat "$PID_FILE") log=${LOG_DIR}/pm_loop.log"
    ;;
  stop)
    [ -f "$PID_FILE" ] || { echo "not running"; exit 0; }
    pid="$(cat "$PID_FILE")"
    kill "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    echo "stopped"
    ;;
  status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "running pid=$(cat "$PID_FILE")"
    else
      echo "stopped"
      exit 1
    fi
    ;;
  *)
    echo "usage: $0 {start|stop|status}"
    exit 2
    ;;
esac
