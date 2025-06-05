#!/usr/bin/env bash
set -euo pipefail

# ---------- 1. Homebrew core ----------
brew install zsh starship oh-my-posh # zsh already on macOS but good for Linux
brew install eza fd ripgrep ripgrep-all fzf bat git-delta difftastic \
             gdu zoxide yazi zellij jless lazygit lazydocker httpie helix \
             tldr navi cheat

# ---------- 2. AI & doc helpers ----------
pipx install --include-deps shell-gpt llm osh readme-ai redacter
npm install -g @diagramgpt/cli devopsgpt  # diagram & devops tools (Node)

# ChatGPT‑Code‑Plugin (Rust)
cargo install chatgpt-code-plugin

# ---------- 3. Oh My Zsh & plugins ----------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true

# ---------- 4. Starship palette ----------
mkdir -p ~/.config
if [[ ! -d ~/.config/.starship-colours ]]; then
  git clone --depth=1 https://github.com/aharoJ/starship-config ~/.config/.starship-colours
fi
ln -sf ~/.config/.starship-colours/starship.toml ~/.config/starship.toml
grep -q "starship init zsh" ~/.zshrc || echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# ---------- 5. zoxide & FZF bindings ----------
grep -q "zoxide init" ~/.zshrc || echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

echo "✅  dDd‑dev‑env toolchain installed.  Open a new terminal or run 'exec zsh'."

