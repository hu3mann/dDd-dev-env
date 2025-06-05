# dDd-dev-env Dockerfile (Debian 12/bookworm-slim)

FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

# Install core tools (GitHub CLI, jq, ripgrep, fzf, bat, httpie, Node, Python3, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      zsh \
      git \
      gh \
      nano \
      wget \
      unzip \
      fonts-powerline \
      gnupg \
      software-properties-common \
      python3 \
      python3-pip \
      python3-pipx \
      nodejs \
      npm \
      ripgrep \
      fzf \
      bat \
      httpie \
      fd-find \
      exa \
      jq \
      diffutils \
      htop && \
    # Link 'fd' for convenience
    ln -s /usr/bin/fdfind /usr/bin/fd && \
    # Install gdu manually
    wget -qO /tmp/gdu.deb https://github.com/dundee/gdu/releases/download/v5.19.0/gdu_5.19.0_linux_amd64.deb && \
    dpkg -i /tmp/gdu.deb && rm /tmp/gdu.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Nerd Font (Fira Code) and update font cache
RUN mkdir -p /usr/share/fonts/truetype/nerd && \
    cd /usr/share/fonts/truetype/nerd && \
    curl -fLo FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && \
    unzip FiraCode.zip && rm FiraCode.zip && \
    fc-cache -f -v

# Use Zsh for subsequent RUN commands
SHELL ["/bin/zsh", "-c"]

# Set default data path (can be overridden at runtime)
ENV DEV_DATA_PATH=/dDd-Dev

# In Codespaces, persist DEV_DATA_PATH
RUN if [[ -n "$CODESPACES" ]]; then \
      echo "DEV_DATA_PATH=/dDd-Dev" >> /etc/environment; \
    fi

# Install Oh My Zsh for root
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# Create root's .zshrc to load dotfiles, Starship, and plugins
RUN cat << 'EOF' > /root/.zshrc
# Load user dotfiles if present
if [[ -f "$DEV_DATA_PATH/.dotfiles/.zshrc" ]]; then
  source "$DEV_DATA_PATH/.dotfiles/.zshrc"
fi
# Initialize Starship prompt
eval "$(starship init zsh)"
# Oh My Zsh initialization
export ZSH=/root/.oh-my-zsh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
alias dDd="$DEV_DATA_PATH"
EOF

# Install Python-based CLI tools via pipx (as user ddd later)
RUN python3 -m pip install --upgrade pip setuptools wheel

# Switch back to bash to create user
SHELL ["/bin/bash", "-c"]

# Create non-root user 'ddd' with Zsh login shell
RUN useradd -m -s /usr/bin/zsh ddd

# Prepare the /dDd-Dev folder and dotfiles mount
RUN mkdir -p /dDd-Dev/.dotfiles && chown -R ddd:ddd /dDd-Dev

USER ddd
WORKDIR /home/ddd

# Install Python CLI tools (as user) via pipx
RUN python3 -m pip install --user pipx && \
    ~/.local/bin/pipx ensurepath && \
    ~/.local/bin/pipx install shell-gpt llm osh readme-ai redacter

# Set entrypoint script (must be provided in the repo)
COPY --chown=ddd:ddd entrypoint.sh /home/ddd/entrypoint.sh
RUN chmod +x /home/ddd/entrypoint.sh

ENTRYPOINT ["/home/ddd/entrypoint.sh"]
WORKDIR /workspace
CMD ["zsh"]
