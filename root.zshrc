# Oh-My-Zsh core
export ZSH="/root/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting wp-cli cli_codex)

# Starship theme (aharoJ)
eval "$(starship init zsh)"

# fzf key-bindings & completion (Debian package paths)
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] &&   source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] &&   source /usr/share/doc/fzf/examples/completion.zsh

# Load private dotfiles if mounted or cloned
[[ -f "/dDd-Dev/.dotfiles/.zshrc" ]] && source "/dDd-Dev/.dotfiles/.zshrc"

alias dDd="/dDd-Dev"

# --- cli_codex setup ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/cli_codex" ]]; then
  git clone --depth=1 https://github.com/tom-doerr/zsh_codex "$ZSH_CUSTOM/plugins/cli_codex" && \
  mv "$ZSH_CUSTOM/plugins/cli_codex/zsh_codex.plugin.zsh" "$ZSH_CUSTOM/plugins/cli_codex/cli_codex.plugin.zsh"
fi

if [[ -n "$OPEN_AI_API_KEY" && ! -f "$HOME/.config/zsh_codex.ini" ]]; then
  mkdir -p "$HOME/.config"
  cat <<EOF > "$HOME/.config/zsh_codex.ini"
[service]
service = openai_service

[openai_service]
api_type = openai
api_key = $OPEN_AI_API_KEY
model = gpt-4o-mini
EOF
fi
