#!/usr/bin/env bash
set -e
DOTS="/dDd-Dev/.dotfiles"
if [[ ! -d "$DOTS" ]]; then
  echo "[dDd‑dev‑env] Cloning private dotfiles..."
  git clone --depth=1 [email protected]:hu3mann/dotfiles.git "$DOTS" || true
fi
exec "$@"
