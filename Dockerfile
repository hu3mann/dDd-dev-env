# ┌────────────────────────────────────────────────────────────────────────────┐
# │   dDd-dev-env Dockerfile (Debian Bookworm-Slim, updated)                    │
# └────────────────────────────────────────────────────────────────────────────┘

FROM debian:bookworm-slim

# Use noninteractive frontend
ENV DEBIAN_FRONTEND=noninteractive

# 1) Core apt installs: your original list plus extras that exist in Debian
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
      # zsh plugins (install via apt so Oh My Zsh can pick them up)
      zsh-autosuggestions \
      zsh-syntax-highlighting \
      # === new/extra tools via apt if available in Debian Bookworm ===
      fd-find \
      ripgrep-all \
      exa \
      jq \
      git-delta \
      diffutils \
      fd-find \
      htop \
      # gdu (not in Bookworm by default; install from backports)
      && \
    # Install gdu from a direct .deb since Debian Bookworm has no gdu package
    wget -qO /tmp/gdu.deb https://github.com/dundee/gdu/releases/download/v5.19.0/gdu_5.19.0_linux_amd64.deb && \
    dpkg -i /tmp/gdu.deb && rm /tmp/gdu.deb && \
    # Clean up Apt caches
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

# Use zsh as the default shell for the subsequent RUNs
SHELL ["/bin/zsh", "-c"]

# 4) Set DEV_DATA_PATH; can be overridden via environment
ENV DEV_DATA_PATH=/dDd-Dev

# If running in Codespaces, persist DEV_DATA_PATH in /etc/environment
RUN if [[ -n "$CODESPACES" ]]; then \
      echo "DEV_DATA_PATH=/dDd-Dev" >> /etc/environment; \
    fi

# 5) Install Oh My Zsh (noninteractive, default directory /root/.oh-my-zsh)
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# 6) Create a minimal ~/.zshrc that:
#    • sources $DEV_DATA_PATH/.dotfiles/.zshrc if it exists
#    • initializes Starship, Oh My Zsh, and plugins
RUN echo '# ────────────────────────────────────────────────────────────────────────────'   >> /root/.zshrc && \
    echo '# Load user dotfiles if available'                                              >> /root/.zshrc && \
    echo 'if [[ -f "$DEV_DATA_PATH/.dotfiles/.zshrc" ]]; then source "$DEV_DATA_PATH/.dotfiles/.zshrc"; fi' >> /root/.zshrc && \
    echo ''                                                                              >> /root/.zshrc && \
    echo '# Initialize Starship prompt'                                                   >> /root/.zshrc && \
    echo 'eval "$(starship init zsh)"'                                                    >> /root/.zshrc && \
    echo ''                                                                              >> /root/.zshrc && \
    echo '# Load Oh My Zsh and selected plugins'                                         >> /root/.zshrc && \
    echo 'export ZSH=/root/.oh-my-zsh'                                                    >> /root/.zshrc && \
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'                     >> /root/.zshrc && \
    echo 'source $ZSH/oh-my-zsh.sh'                                                       >> /root/.zshrc && \
    echo ''                                                                              >> /root/.zshrc && \
    echo '# Alias to quickly jump to DEV_DATA_PATH'                                       >> /root/.zshrc && \
    echo 'alias dDd="$DEV_DATA_PATH"'                                                     >> /root/.zshrc

# 7) Install Python-based AI/CLI tools via pipx
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install --user pipx && \
    ~/.local/bin/pipx ensurepath && \
    ~/.local/bin/pipx install shell-gpt && \
    ~/.local/bin/pipx install llm && \
    ~/.local/bin/pipx install osh && \
    ~/.local/bin/pipx install readme-ai && \
    ~/.local/bin/pipx install redacter

# 8) Install Node-based AI/CLI tools via npm
RUN npm install -g @diagramgpt/cli devopsgpt

# 9) Install Rust toolchain (needed for chatgpt-code-plugin)
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source "$HOME/.cargo/env" && \
    cargo install chatgpt-code-plugin

# 10) Switch back to bash for remaining apt cleanup (if any)
SHELL ["/bin/bash", "-c"]

# 11) Create a non-root user "ddd" and set Zsh as its shell
RUN useradd -m -s /usr/bin/zsh ddd

USER ddd
WORKDIR /home/ddd

# 12) Create placeholder for dotfiles mount inside /dDd-Dev
RUN mkdir -p /dDd-Dev/.dotfiles

# 13) Create entrypoint script (runs as user 'ddd')
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
  echo "⚠️  No ~/.dotfiles/.zshrc found. Please mount your dotfiles at /dDd-Dev/.dotfiles"
fi

# 3) Exec Zsh as login
exec /usr/bin/zsh --login
EOF

RUN chmod +x /home/ddd/entrypoint.sh

# 14) Set entrypoint and default command
ENTRYPOINT ["/home/ddd/entrypoint.sh"]
WORKDIR /workspace
CMD ["zsh"]
