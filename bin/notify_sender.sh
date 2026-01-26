#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
require_env DATABASE_URL

ROWS="$(psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -t -A <<'SQL'
select outbox_id::text || '|' || channel || '|' || destination || '|' || payload::text
from ops.notification_outbox
where status='queued'
order by created_at asc
limit 10;
SQL
)" || exit 0

[ -n "$ROWS" ] || exit 0

echo "$ROWS" | while IFS= read -r line; do
  [ -n "$line" ] || continue
  ID="$(printf "%s" "$line" | awk -F'|' '{print $1}')"
  CH="$(printf "%s" "$line" | awk -F'|' '{print $2}')"
  DST="$(printf "%s" "$line" | awk -F'|' '{print $3}')"
  PAY="$(printf "%s" "$line" | cut -d'|' -f4- )"

  ok=0; err=""
  if [ "$CH" = "slack" ]; then
    if curl -fsS -X POST -H 'Content-type: application/json' --data "$PAY" "$DST" >/dev/null 2>&1; then ok=1; else err="slack post failed"; fi
  elif [ "$CH" = "line" ]; then
    if [ -n "${LINE_NOTIFY_TOKEN:-}" ]; then
      MSG="$(printf "%s" "$PAY" | sed -n 's/.*"message"[ ]*:[ ]*"\(.*\)".*/\1/p' | head -n1)"
      [ -n "$MSG" ] || MSG="$PAY"
      if curl -fsS -X POST -H "Authorization: Bearer ${LINE_NOTIFY_TOKEN}" -d "message=${MSG}" https://notify-api.line.me/api/notify >/dev/null 2>&1; then ok=1; else err="line notify failed"; fi
    else
      err="LINE_NOTIFY_TOKEN empty"
    fi
  else
    err="unknown channel"
  fi

  if [ "$ok" -eq 1 ]; then
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "select ops.mark_notification_sent(${ID});" >/dev/null
  else
    esc="$(printf "%s" "$err" | sed "s/'/''/g")"
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "select ops.mark_notification_failed(${ID},'${esc}');" >/dev/null
  fi
done
