FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl zsh git nano wget unzip fonts-powerline \
    gnupg software-properties-common python3 python3-pip \
    nodejs npm ripgrep fzf bat httpie \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Nerd Fonts (Fira Code)
RUN mkdir -p /usr/share/fonts/truetype/nerd && \
    cd /usr/share/fonts/truetype/nerd && \
    curl -fLo FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && \
    unzip FiraCode.zip && \
    rm FiraCode.zip

ENV ZSH=/root/.oh-my-zsh
ENV ZSH_CUSTOM=$ZSH/custom

# Install Oh My Zsh and plugins (zsh-autosuggestions, zsh-syntax-highlighting)
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git $ZSH && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Create default .zshrc: initializes DEV_DATA_PATH, Starship, Oh My Zsh, and plugins
RUN cat << 'EOF' > /root/.zshrc
# Setup DEV_DATA_PATH; override via environment variable
export DEV_DATA_PATH=${DEV_DATA_PATH:-/dDd-Dev}
if [[ -n "$CODESPACES" ]]; then
  DEV_DATA_PATH=/dDd-Dev
fi

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

# Use Zsh as the default shell for subsequent commands
SHELL ["/bin/zsh", "-c"]
