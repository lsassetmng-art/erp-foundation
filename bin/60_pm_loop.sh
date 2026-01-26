#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"
SLEEP_SEC="${PM_LOOP_SLEEP_SEC:-15}"
LOG="$ERP_HOME/logs/pm_loop.log"
PIDFILE="$ERP_HOME/run/pm_loop.pid"

mkdir -p "$ERP_HOME/logs" "$ERP_HOME/run"
touch "$LOG"

log(){ printf '%s %s\n' "$(date -Is)" "$*" >>"$LOG"; }

is_killed() {
  psql "$DATABASE_URL" -tA -v ON_ERROR_STOP=1 -c "
    SELECT CASE
      WHEN to_regclass('system.runtime_killswitch') IS NULL THEN 'false'
      ELSE coalesce((SELECT enabled::text FROM system.runtime_killswitch ORDER BY updated_at DESC LIMIT 1),'false')
    END;
  " 2>/dev/null | tr -d '[:space:]' | grep -qi '^true$' && return 0 || return 1
}

echo $$ > "$PIDFILE"
log "pm_loop start (sleep=${SLEEP_SEC}s)"
"$ERP_HOME/bin/notify.sh" "pm_loop start"

while true; do
  if is_killed; then
    log "KILL-SWITCH enabled -> exit 99"
    "$ERP_HOME/bin/notify.sh" "KILL-SWITCH enabled -> pm_loop stopped"
    exit 99
  fi

  # Phase5a: proposal worker (marks reviewed)
  if "$ERP_HOME/bin/51_policy_worker_once.sh" >>"$LOG" 2>&1; then :; else
    log "proposal worker failed"
    "$ERP_HOME/bin/notify.sh" "proposal worker failed"
  fi

  # Phase5b/14/20: apply worker (freeze+lock+exec-log)
  if "$ERP_HOME/bin/52_policy_apply_worker_once.sh" >>"$LOG" 2>&1; then :; else
    log "apply worker failed"
    "$ERP_HOME/bin/notify.sh" "apply worker failed"
  fi

  # Phase18: rollback worker
  if "$ERP_HOME/bin/53_rollback_worker_once.sh" >>"$LOG" 2>&1; then :; else
    log "rollback worker failed"
    "$ERP_HOME/bin/notify.sh" "rollback worker failed"
  fi

  # Phase17: anomaly scan (light)
  if "$ERP_HOME/bin/54_anomaly_scan_once.sh" >>"$LOG" 2>&1; then :; else
    log "anomaly scan failed"
  fi

  sleep "$SLEEP_SEC"
done
