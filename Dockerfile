RUN cat << 'EOF' > /root/.zshrc
# Load user dotfiles if available
\[\[ -f "$DEV_DATA_PATH/.dotfiles/.zshrc" \]\] && source "$DEV_DATA_PATH/.dotfiles/.zshrc"

# Initialize Starship prompt
eval "$(starship init zsh)"

# Load Oh My Zsh plugins
export ZSH=/root/.oh-my-zsh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

alias dDd="$DEV_DATA_PATH"
EOF