# dDd‑dev‑env/Dockerfile  — Debian 12 slim
FROM debian:bookworm-slim

# --- 1. core OS packages & CLIs --------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl zsh git gh nano wget unzip gnupg \
      software-properties-common jq diffutils htop \
      python3 python3-pip nodejs npm ripgrep fzf bat \
      fd-find exa httpie mariadb-client php php-mysql && \
    ln -s /usr/bin/fdfind /usr/bin/fd && \
    rm -rf /var/lib/apt/lists/*

# --- 2. Starship prompt & Nerd Font ----------------------------------------
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y && \
    mkdir -p /usr/share/fonts/truetype/nerd && \
    curl -L -o /tmp/FiraCode.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && \
    unzip -q /tmp/FiraCode.zip -d /usr/share/fonts/truetype/nerd && \
    rm /tmp/FiraCode.zip && fc-cache -f -v

# --- 3. Oh‑My‑Zsh without heredoc trouble ----------------------------------
COPY root.zshrc /root/.zshrc          # <- keep this file in repo
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# --- 4. non‑root dev user ---------------------------------------------------
RUN useradd -m -s /usr/bin/zsh ddd
USER ddd
WORKDIR /home/ddd

# --- 5. install WP‑CLI + requested plugins ---------------------------------
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info && chmod +x wp-cli.phar && mv wp-cli.phar ~/bin/wp && \
    mkdir ~/wp-cli && cd ~/wp-cli && \
    wp plugin install ai-engine jetpack rank-math-seo \
      bertha-ai 10web-ai simply-static-pro wp2static --activate --allow-root

# --- 6. entrypoint clones dotfiles if missing -------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["zsh"]
