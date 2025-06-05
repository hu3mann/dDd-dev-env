# ┌────────────────────────────────────────────────────────────────────────────┐
# │   dDd-dev-env Dockerfile (Ubuntu 22.04, corrected)                        │
# └────────────────────────────────────────────────────────────────────────────┘

# 1) Base image: Ubuntu 22.04
FROM ubuntu:22.04

# 2) Prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# 3) Install core packages via apt (omit ripgrep-all and git-delta)
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
    # Install gdu manually (Ubuntu 22.04 has no gdu package in default repos)
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

# 6) Switch default shell for subsequent RUN steps to zsh
SHELL ["/bin/zsh", "-c"]

# 7) Set DEV_DATA_PATH (can be overridden at runtime)
ENV DEV_DATA_PATH=/dDd-Dev

# 8) If running in Codespaces, persist DEV_DATA_PATH in /etc/environment
RUN if [[ -n "$CODESPACES" ]]; then \
      echo "DEV_DATA_PATH=/dDd-Dev" >> /etc/environment; \
    fi

# 9) Install Oh My Zsh (noninteractive; clones into /root/.oh-my-zsh)
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# 10) Create /root/.zshrc that:
#     • Sources $DEV_DATA_PATH/.dotfiles/.zshrc if available
#     • Initializes Starship
#     • Loads Oh My Zsh + selected plugins
RUN cat << 'EOF' > /root/.zshrc
# ────────────────────────────────────────────────────────────────────────────
# Load user dotfiles if available
if [[ -f "$DEV_DATA_PATH/.dotfiles/.zshrc" ]]; then
  source "$DEV_DATA_PATH/.dotfiles/.zshrc"
fi

# Initialize Starship prompt
eval "$(starship init zsh)"

# Load Oh My Zsh and selected plugins
export ZSH=/root/.oh-my-zsh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source \$ZSH/oh-my-zsh.sh

# Alias to quickly jump to DEV_DATA_PATH
alias dDd="\$DEV_DATA_PATH"
EOF

# 11) Install Python‐based AI/CLI tools via pipx
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install --user pipx && \
    ~/.local/bin/pipx ensurepath && \
    ~/.local/bin/pipx install shell-gpt && \
    ~/.local/bin/pipx install llm && \
    ~/.local/bin/pipx install osh && \
    ~/.local/bin/pipx install readme-ai && \
    ~/.local/bin/pipx install redacter

# 12) Install Node‐based AI/CLI tools via npm
RUN npm install -g @diagramgpt/cli devopsgpt

# 13) Install Rust toolchain & Rust‐based tools (chatgpt-code-plugin + ripgrep-all + git-delta)
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source "$HOME/.cargo/env" && \
    cargo install chatgpt-code-plugin && \
    cargo install ripgrep_all && \
    cargo install git-delta

# 14) Switch back to bash for user creation
SHELL ["/bin/bash", "-c"]

# 15) Create non‐root user "ddd" with zsh as its login shell
RUN useradd -m -s /usr/bin/zsh ddd

# 16) Switch to user "ddd" for the remaining steps
USER ddd
WORKDIR /home/ddd

# 17) Create placeholder directory for dotfiles to be mounted at runtime
RUN mkdir -p /dDd-Dev/.dotfiles

# 18) Copy the external entrypoint.sh (must exist at repo root)
COPY --chown=ddd:ddd entrypoint.sh /home/ddd/entrypoint.sh

# 19) Make entrypoint.sh executable
RUN chmod +x /home/ddd/entrypoint.sh

# 20) Set entrypoint and default command
ENTRYPOINT ["/home/ddd/entrypoint.sh"]
WORKDIR /workspace
CMD ["zsh"]
