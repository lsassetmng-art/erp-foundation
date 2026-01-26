#!/data/data/com.termux/files/usr/bin/sh
set -eu
now_iso(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
run_id(){ date -u +"%Y%m%dT%H%M%SZ"; }
log(){ printf "%s [%s] %s\n" "$(now_iso)" "$1" "$2" >&2; }
