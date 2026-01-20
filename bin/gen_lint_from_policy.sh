#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
POLICY="$ROOT/pm_ai/policy.yaml"
LINT="$ROOT/bin/pm_lint.sh"

cat <<'SH' > "$LINT"
#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
LOG_DIR="$ROOT/logs"
INBOX="$ROOT/pm_ai/inbox"
mkdir -p "$LOG_DIR"
NOW="$(date '+%Y-%m-%d %H:%M:%S')"
NG=""

if [ ! -d "$INBOX" ] || ! ls "$INBOX"/* >/dev/null 2>&1; then
  NG="no task in inbox"
fi

if [ -z "$NG" ]; then
  for F in "$INBOX"/*; do
    [ -f "$F" ] || continue
    [ -s "$F" ] || NG="empty task: $(basename "$F")"
    grep -qiE 'TODO|仮|guess' "$F" && NG="forbidden word in $(basename "$F")"
    [ -n "$NG" ] && break
  done
fi

if [ -n "$NG" ]; then
  echo "[$NOW] NG: $NG" > "$LOG_DIR/pm_lint.last"
  exit 4
fi

echo "[$NOW] OK" > "$LOG_DIR/pm_lint.last"
exit 0
SH

chmod +x "$LINT"
