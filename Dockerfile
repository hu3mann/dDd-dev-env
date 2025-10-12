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
FROM debian:bookworm-slim

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

# --- 1. Core OS packages & CLIs ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl zsh git gh nano wget unzip gnupg \
      software-properties-common jq diffutils htop \
      python3 python3-pip nodejs npm ripgrep fzf bat \
      fd-find exa httpie mariadb-client php php-mysql \
      fontconfig && \
    ln -s /usr/bin/fdfind /usr/bin/fd && \
    rm -rf /var/lib/apt/lists/*

# --- 2. Starship prompt & Nerd Font (FiraCode) ---
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y && \
    mkdir -p /root/.config/starship && \
    mkdir -p /usr/share/fonts/truetype/nerd && \
    curl -L -o /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && \
    unzip -q /tmp/FiraCode.zip -d /usr/share/fonts/truetype/nerd && \
    rm /tmp/FiraCode.zip && fc-cache -f -v

# --- 3. Oh-My-Zsh, shell plugins, and configs ---
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh \
 && git clone --depth=1 https://github.com/tom-doerr/zsh_codex /root/.oh-my-zsh/custom/plugins/cli_codex \
 && mv /root/.oh-my-zsh/custom/plugins/cli_codex/zsh_codex.plugin.zsh /root/.oh-my-zsh/custom/plugins/cli_codex/cli_codex.plugin.zsh

COPY root.zshrc /root/.zshrc
COPY starship.toml /root/.config/starship/starship.toml

# --- 4. Non-root user (ddd), same Starship config for ddd ---
RUN useradd -m -s /usr/bin/zsh ddd && \
    install -d -o ddd -g ddd /home/ddd/.config/starship && \
    cp /root/.config/starship/starship.toml /home/ddd/.config/starship/starship.toml && \
    cp -r /root/.oh-my-zsh /home/ddd/.oh-my-zsh && \
    cp /root/.zshrc /home/ddd/.zshrc && \
    sed -i 's|/root|/home/ddd|g' /home/ddd/.zshrc && \
    chown -R ddd:ddd /home/ddd

USER ddd
WORKDIR /home/ddd
