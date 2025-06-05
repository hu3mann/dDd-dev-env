# ┌────────────────────────────────────────────────────────────────────────────┐
# │   dDd-dev-env Dockerfile (Debian Bookworm-Slim, fixed here-doc)           │
# └────────────────────────────────────────────────────────────────────────────┘

FROM debian:bookworm-slim

# Use non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# 1) Install core packages via apt
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      zsh \
      git \
      nano \
      wget \
      unzip \
      fonts-powerline \
      gnupg \
      software-properties-common \
      python3 \
      python3-pip \
      nodejs \
      npm \
      ripgrep \
      fzf \
      bat \
      httpie \
      zsh-autosuggestions \
      zsh-syntax-highlighting \
      fd-find \
      ripgrep-all \
      exa \
      jq \
      git-delta \
      diffutils \
      htop && \
    # Install gdu manually (Bookworm has no gdu package)
    wget -qO /tmp/gdu.deb \
      https://github.com/dundee/gdu/releases/download/v5.19.0/gdu_5.19.0_linux_amd64.deb && \
    dpkg -i /tmp/gdu.deb && \
    rm /tmp/gdu.deb && \
    # Clean up apt caches
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2) Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# 3) Install Nerd Fonts (Fira Code)
RUN mkdir -p /usr/share/fonts/truetype/nerd && \
    cd /usr/share/fonts/truetype/nerd && \
    curl -fLo FiraCode.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && \
    unzip FiraCode.zip && \
    rm FiraCode.zip

# Switch default shell for RUN steps to zsh
SHELL ["/bin/zsh", "-c"]

# 4) Set DEV_DATA_PATH (overrideable via environment)
ENV DEV_DATA_PATH=/dDd-Dev

# 5) In Codespaces, persist DEV_DATA_PATH for future sessions
RUN if [[ -n "$CODESPACES" ]]; then \
      echo "DEV_DATA_PATH=/dDd-Dev" >> /etc/environment; \
    fi

# 6) Install Oh My Zsh (so /root/.oh-my-zsh exists)
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# 7) Create a minimal /root/.zshrc that:
#    • Sources $DEV_DATA_PATH/.dotfiles/.zshrc if it exists
#    • Initializes Starship
#    • Loads Oh My Zsh and plugins
RUN echo '# ────────────────────────────────────────────────────────────────────────────' >> /root/.zshrc && \
    echo '# Load user dotfiles if available' >> /root/.zshrc && \
    echo 'if [[ -f "$DEV_DATA_PATH/.dotfiles/.zshrc" ]]; then source "$DEV_DATA_PATH/.dotfiles/.zshrc"; fi' >> /root/.zshrc && \
    echo '' >> /root/.zshrc && \
    echo '# Initialize Starship prompt' >> /root/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> /root/.zshrc && \
    echo '' >> /root/.zshrc && \
    echo '# Load Oh My Zsh and selected plugins' >> /root/.zshrc && \
    echo 'export ZSH=/root/.oh-my-zsh' >> /root/.zshrc && \
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> /root/.zshrc && \
    echo 'source $ZSH/oh-my-zsh.sh' >> /root/.zshrc && \
    echo '' >> /root/.zshrc && \
    echo '# Alias to quickly jump to DEV_DATA_PATH' >> /root/.zshrc && \
    echo 'alias dDd="$DEV_DATA_PATH"' >> /root/.zshrc

# 8) Install Python-based AI/CLI tools via pipx
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install --user pipx && \
    ~/.local/bin/pipx ensurepath && \
    ~/.local/bin/pipx install shell-gpt && \
    ~/.local/bin/pipx install llm && \
    ~/.local/bin/pipx install osh && \
    ~/.local/bin/pipx install readme-ai && \
    ~/.local/bin/pipx install redacter

# 9) Install Node-based AI/CLI tools via npm
RUN npm install -g @diagramgpt/cli devopsgpt

# 10) Install Rust toolchain & chatgpt-code-plugin
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source "$HOME/.cargo/env" && \
    cargo install chatgpt-code-plugin

# Switch back to bash for any leftover steps
SHELL ["/bin/bash", "-c"]

# 11) Create a non-root user "ddd" with zsh as its login shell
RUN useradd -m -s /usr/bin/zsh ddd

# Switch to user ddd for the rest
USER ddd
WORKDIR /home/ddd

# 12) Create a placeholder for dotfiles mount at runtime
RUN mkdir -p /dDd-Dev/.dotfiles

# 13) Create entrypoint.sh (runs at container start, as user 'ddd')
COPY --chown=ddd:ddd << 'EOF' /home/ddd/entrypoint.sh
#!/usr/bin/env bash
set -euo pipefail

# 1) If /dDd-Dev/.dotfiles exists, symlink it to ~/.dotfiles
if [[ -d "/dDd-Dev/.dotfiles" ]]; then
  rm -rf "$HOME/.dotfiles"
  ln -s /dDd-Dev/.dotfiles "$HOME/.dotfiles"
fi

# 2) If ~/.dotfiles/.zshrc exists, source it; otherwise, warn
if [[ -f "$HOME/.dotfiles/.zshrc" ]]; then
  source "$HOME/.dotfiles/.zshrc"
else
  echo "⚠️  No ~/.dotfiles/.zshrc found. Mount your dotfiles at /dDd-Dev/.dotfiles"
fi

# 3) Exec Zsh as a login shell
exec /usr/bin/zsh --login
EOF

# Make entrypoint executable
RUN chmod +x /home/ddd/entrypoint.sh

# 14) Set entrypoint and default command
ENTRYPOINT ["/home/ddd/entrypoint.sh"]
WORKDIR /workspace
CMD ["zsh"]
