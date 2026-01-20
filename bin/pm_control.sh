#!/bin/sh
ROOT="$HOME/erp-foundation"
CTRL="$ROOT/control"
mkdir -p "$CTRL"

case "$1" in
  stop)  touch "$CTRL/STOP" ;;
  start) rm -f "$CTRL/STOP" ;;
  *) exit 1 ;;
esac
exit 0
