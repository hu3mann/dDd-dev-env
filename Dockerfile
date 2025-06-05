FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl zsh git nano wget unzip fonts-powerline \
    gnupg software-properties-common python3 python3-pip \
    nodejs npm ripgrep fzf bat httpie \
    zsh-autosuggestions zsh-syntax-highlighting \
    exa htop tmux \
    && apt-get clean

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Nerd Fonts (Fira Code)
RUN mkdir -p /usr/share/fonts/truetype/nerd && \
    cd /usr/share/fonts/truetype/nerd && \
    curl -fLo FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && \
    unzip FiraCode.zip && \
    rm FiraCode.zip

SHELL ["/bin/zsh", "-c"]

# Setup DEV_DATA_PATH; override via environment variable
ENV DEV_DATA_PATH=/dDd-Dev

# In Codespaces, persist DEV_DATA_PATH to /etc/environment for future sessions
RUN if [ -n "$CODESPACES" ]; then \
      echo "DEV_DATA_PATH=/dDd-Dev" >> /etc/environment; \
    fi

# Create default .zshrc: initializes Starship, Oh My Zsh, and plugins
RUN echo '# Load user dotfiles if available' >> /root/.zshrc && \
    echo 'if [ -f "$DEV_DATA_PATH/.dotfiles/.zshrc" ]; then source "$DEV_DATA_PATH/.dotfiles/.zshrc"; fi' >> /root/.zshrc && \
    echo '' >> /root/.zshrc && \
    echo '# Initialize Starship prompt' >> /root/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> /root/.zshrc && \
    echo '' >> /root/.zshrc && \
    echo '# Load Oh My Zsh plugins' >> /root/.zshrc && \
    echo 'export ZSH=/root/.oh-my-zsh' >> /root/.zshrc && \
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> /root/.zshrc && \
    echo 'source $ZSH/oh-my-zsh.sh' >> /root/.zshrc && \
    echo '' >> /root/.zshrc && \
    echo 'alias dDd="$DEV_DATA_PATH"' >> /root/.zshrc && \
    echo '' >> /root/.zshrc && \
    echo '# Convenience aliases and env vars' >> /root/.zshrc && \
    echo 'alias ls="exa --icons"' >> /root/.zshrc && \
    echo 'alias ll="ls -alF"' >> /root/.zshrc && \
    echo 'alias la="ls -A"' >> /root/.zshrc && \
    echo 'alias l="ls -CF"' >> /root/.zshrc && \
    echo 'alias cat="bat"' >> /root/.zshrc && \
    echo 'export EDITOR=nano' >> /root/.zshrc
