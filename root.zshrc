export ZSH="/root/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting wp-cli)
source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# Load private dotfiles when mounted/cloned
[[ -f "/dDd-Dev/.dotfiles/.zshrc" ]] && source /dDd-Dev/.dotfiles/.zshrc
alias dDd="/dDd-Dev"
