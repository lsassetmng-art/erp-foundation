#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
: "${DATABASE_URL:?}"

ROW="$(psql "$DATABASE_URL" -t -A -v ON_ERROR_STOP=1 -c \
"select notify_id||'|'||coalesce(company_id::text,'')||'|'||coalesce(title,'')||'|'||coalesce(body,'')||'|'||coalesce(severity,'')
 from ops.pop_notify_queue();" 2>/dev/null || true)"
ROW="$(printf "%s" "$ROW" | tr -d '\r' | sed '/^[[:space:]]*$/d' | head -n1 || true)"

if [ -z "$ROW" ]; then exit 0; fi

ID="$(printf "%s" "$ROW" | cut -d'|' -f1)"
TITLE="$(printf "%s" "$ROW" | cut -d'|' -f3)"
BODY="$(printf "%s" "$ROW" | cut -d'|' -f4)"
SEV="$(printf "%s" "$ROW" | cut -d'|' -f5)"

MSG="$(printf "[%s]\n%s\n%s\n" "$SEV" "$TITLE" "$BODY")"

if "$(dirname "$0")/line_send.sh" "$MSG" 2>/dev/null; then
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "select ops.mark_notify_sent(${ID});" >/dev/null
  log OK "notify sent id=${ID}"
else
  ERR="line_send failed"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "select ops.mark_notify_failed(${ID}, \$j\$${ERR}\$j\$);" >/dev/null || true
  log WARN "notify failed id=${ID}"
fi
