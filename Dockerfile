# … lines 1–2 unchanged …

# 3) Install core packages via apt (minus ripgrep-all and git-delta)
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
      exa \
      jq \
      diffutils \
      htop && \
    # Install gdu manually (Bookworm has no gdu package)
    wget -qO /tmp/gdu.deb \
      https://github.com/dundee/gdu/releases/download/v5.19.0/gdu_5.19.0_linux_amd64.deb && \
    dpkg -i /tmp/gdu.deb && \
    rm /tmp/gdu.deb && \
    # Clean up apt caches
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 4) Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# 5) Install Nerd Fonts (Fira Code)
RUN mkdir -p /usr/share/fonts/truetype/nerd && \
    cd /usr/share/fonts/truetype/nerd && \
    curl -fLo FiraCode.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && \
    unzip FiraCode.zip && \
    rm FiraCode.zip

# 6) Switch default shell for RUN steps to zsh
SHELL ["/bin/zsh", "-c"]

# 7) Set DEV_DATA_PATH (overrideable via environment)
ENV DEV_DATA_PATH=/dDd-Dev

# 8) If running in Codespaces, persist DEV_DATA_PATH
RUN if [[ -n "$CODESPACES" ]]; then \
      echo "DEV_DATA_PATH=/dDd-Dev" >> /etc/environment; \
    fi

# 9) Install Oh My Zsh
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# 10) Create /root/.zshrc
RUN printf '%s\n' \
    '# ────────────────────────────────────────────────────────────────────────────' \
    '# Load user dotfiles if available' \
    'if [[ -f "$DEV_DATA_PATH/.dotfiles/.zshrc" ]]; then source "$DEV_DATA_PATH/.dotfiles/.zshrc"; fi' \
    '' \
    '# Initialize Starship prompt' \
    'eval "$(starship init zsh)"' \
    '' \
    '# Load Oh My Zsh and plugins' \
    'export ZSH=/root/.oh-my-zsh' \
    'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' \
    'source $ZSH/oh-my-zsh.sh' \
    '' \
    '# Alias for DEV_DATA_PATH' \
    'alias dDd="$DEV_DATA_PATH"' \
    > /root/.zshrc

# 11) Install Python‐based AI/CLI tools
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install --user pipx && \
    ~/.local/bin/pipx ensurepath && \
    ~/.local/bin/pipx install shell-gpt && \
    ~/.local/bin/pipx install llm && \
    ~/.local/bin/pipx install osh && \
    ~/.local/bin/pipx install readme-ai && \
    ~/.local/bin/pipx install redacter

# 12) Install Node‐based AI/CLI tools
RUN npm install -g @diagramgpt/cli devopsgpt

# 13) Install Rust toolchain & Rust‐based tools
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source "$HOME/.cargo/env" && \
    cargo install chatgpt-code-plugin && \
    cargo install ripgrep_all && \
    cargo install git-delta

# 14) Switch back to bash to create non-root user
SHELL ["/bin/bash", "-c"]

# 15) Create non-root user "ddd"
RUN useradd -m -s /usr/bin/zsh ddd

# 16) Switch to user "ddd"
USER ddd
WORKDIR /home/ddd

# 17) Create placeholder for dotfiles
RUN mkdir -p /dDd-Dev/.dotfiles

# 18) Add entrypoint script (unindented here-doc)
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

# 19) Make entrypoint executable
RUN chmod +x /home/ddd/entrypoint.sh

# 20) Set entrypoint and default command
ENTRYPOINT ["/home/ddd/entrypoint.sh"]
WORKDIR /workspace
CMD ["zsh"]
