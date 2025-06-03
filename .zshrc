# Set up Oh My Zsh path and Dev Drive variable
export ZSH="/root/.oh-my-zsh"
export DDD="/Volumes/dDd-Dev"

# Alias to quickly load SSH key
alias sshkey="$DDD/.dotfiles/ssh-setup.sh"

# Theme
ZSH_THEME="robbyrussell"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Enable Starship prompt
eval "$(starship init zsh)"

# Load Zsh plugins (manual install locations)
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load aliases
source ~/.aliases

# Set nano as the default editor
export EDITOR=nano
