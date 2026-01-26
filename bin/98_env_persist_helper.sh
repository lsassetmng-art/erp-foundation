#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
mkdir -p "$HOME/.secrets"
SE="$HOME/.secrets/openai.env"

# NOTE: do not echo keys to screen; user sets them by editing file or using heredoc externally
if [ ! -f "$SE" ]; then
  cat > "$SE" <<'E'
# export OPENAI_API_KEY="sk-..."
E
  chmod 600 "$SE"
fi

# Ensure .bashrc sources secrets
if ! grep -q '\.secrets/openai\.env' "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" <<'E'
# ============================================================
# ERP Foundation (persistent env)
# ============================================================
export ERP_HOME="$HOME/erp-foundation"
[ -f "$HOME/.secrets/openai.env" ] && source "$HOME/.secrets/openai.env"
# DATABASE_URL is expected to be set here as well:
# export DATABASE_URL="postgresql://..."
# ============================================================
E
fi

echo "OK: env persist helper prepared"
echo "Next:"
echo "  nano $HOME/.secrets/openai.env   # set OPENAI_API_KEY"
echo "  nano $HOME/.bashrc              # set DATABASE_URL if not yet"
exit 0
