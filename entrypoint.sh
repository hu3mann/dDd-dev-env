#!/usr/bin/env bash
set -euo pipefail

# 1) If /dDd-Dev/.dotfiles exists, symlink it to ~/.dotfiles
if [[ -d "/dDd-Dev/.dotfiles" ]]; then
  rm -rf "$HOME/.dotfiles"
  ln -s /dDd-Dev/.dotfiles "$HOME/.dotfiles"
fi

# 2) If ~/.dotfiles/.zshrc exists, source it; otherwise, warn
if [[ -f "$HOME/.dotfiles/.zshrc" ]]; then
  source "$HOME/.dotfiles/.zshrc"
else
  echo "⚠️  No ~/.dotfiles/.zshrc found. Mount your dotfiles at /dDd-Dev/.dotfiles"
fi

# 3) Exec Zsh as a login shell
exec /usr/bin/zsh --login
