#!/bin/sh
set -e
ENVF="$HOME/.config/erp_foundation.env"
[ -f "$ENVF" ] && . "$ENVF" || true
exit 0
