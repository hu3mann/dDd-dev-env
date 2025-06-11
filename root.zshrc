# Oh-My-Zsh core
export ZSH="/root/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting wp-cli)

# Starship theme (aharoJ)
eval "$(starship init zsh)"

# fzf key-bindings & completion (Debian package paths)
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] &&   source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] &&   source /usr/share/doc/fzf/examples/completion.zsh

# Load private dotfiles if mounted or cloned
[[ -f "/dDd-Dev/.dotfiles/.zshrc" ]] && source "/dDd-Dev/.dotfiles/.zshrc"

alias dDd="/dDd-Dev"
