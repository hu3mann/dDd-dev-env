#!/usr/bin/env bash
set -e

# Bootstrap dotfiles if external drive or mount isn’t present
DOTS="/dDd-Dev/.dotfiles"
if [[ ! -d "$DOTS" ]]; then
  echo "Dotfiles not found, cloning private repo..."
  git clone --depth=1 [email protected]:hu3mann/dotfiles.git "$DOTS" || true
fi

exec "$@"
