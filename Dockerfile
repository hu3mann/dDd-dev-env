FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl zsh git nano wget unzip fonts-powerline \
    gnupg software-properties-common python3 python3-pip \
    nodejs npm ripgrep fzf bat httpie \
    zsh-autosuggestions zsh-syntax-highlighting \
    && apt-get clean

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Nerd Fonts (Fira Code)
RUN mkdir -p /usr/share/fonts/truetype/nerd && \
    cd /usr/share/fonts/truetype/nerd && \
    curl -fLo "FiraCodeNerdFont-Regular.ttf" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && unzip FiraCode.zip && rm FiraCode.zip

SHELL ["/bin/zsh", "-c"]

# Setup DEV_DATA_PATH; override via environment variable
ENV DEV_DATA_PATH=/dDd-Dev

# In Codespaces, persist DEV_DATA_PATH to /etc/environment for future sessions
RUN if [ -n "$CODESPACES" ]; then \
      echo "DEV_DATA_PATH=/dDd-Dev" >> /etc/environment; \
    fi

# Create default .zshrc: initializes Starship, Oh My Zsh, and plugins
RUN cat << 'EOF' > /root/.zshrc
# Load user dotfiles if available
[[ -f "$DEV_DATA_PATH/.dotfiles/.zshrc" ]] && source "$DEV_DATA_PATH/.dotfiles/.zshrc"

# Initialize Starship prompt
eval "$(starship init zsh)"

# Load Oh My Zsh plugins
export ZSH=/root/.oh-my-zsh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

alias dDd="$DEV_DATA_PATH"
EOF

