# ────────────────────────────────────────────────────────────────
# dDd-dev-env/Dockerfile — Debian 12 (bookworm-slim)
# Maintainer: your name/email (optional)
# Description: Dev container with Zsh, Starship, Oh-My-Zsh, WP-CLI, and more!
# ────────────────────────────────────────────────────────────────

FROM debian:bookworm-slim

# ──────────────── 1. Avoid service startups during build ────────────────
RUN echo '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# ──────────────── 2. Core OS packages & CLIs ────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl zsh git gh nano wget unzip gnupg \
      software-properties-common jq diffutils htop \
      python3 python3-pip nodejs npm ripgrep fzf bat \
      fd-find exa httpie mariadb-client php php-mysql \
      fontconfig && \
    ln -s /usr/bin/fdfind /usr/bin/fd && \
    rm -rf /var/lib/apt/lists/*

# ──────────────── 3. Starship prompt & Nerd Font ────────────────────────
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y && \
    mkdir -p /usr/share/fonts/truetype/nerd && \
    curl -L -o /tmp/Hack.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip && \
    unzip -q /tmp/Hack.zip -d /usr/share/fonts/truetype/nerd && \
    rm /tmp/Hack.zip && fc-cache -f -v

# ──────────────── 4. Oh-My-Zsh (no heredoc parsing issues) ──────────────
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# ──────────────── 5. Create non-root dev user ───────────────────────────
RUN useradd -m -s /usr/bin/zsh ddd

# ──────────────── 6. Starship config for dev user ───────────────────────
COPY starship.toml /root/.config/starship/starship.toml
RUN mkdir -p /home/ddd/.config/starship && \
    install -o ddd -g ddd -m 644 /root/.config/starship/starship.toml \
      /home/ddd/.config/starship/starship.toml

# ──────────────── 7. Switch to dev user for safer operations ────────────
USER ddd
WORKDIR /home/ddd

# ──────────────── 8. Install WP-CLI + WordPress plugins ─────────────────
# - Ensures ~/bin exists before mv
# - Installs WP-CLI for user and requested plugins
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info && \
    chmod +x wp-cli.phar && \
    mkdir -p ~/bin && \
    mv wp-cli.phar ~/bin/wp && \
    mkdir -p ~/wp-cli && \
    cd ~/wp-cli && \
    wp plugin install \
      ai-engine \
      jetpack \
      rank-math-seo \
      bertha-ai \
      10web-ai \
      simply-static-pro \
      wp2static \
      --activate --allow-root

# ──────────────── 9. Install additional WP plugins system-wide ──────────
USER root
RUN mkdir -p /var/www && cd /var/www && \
    wp plugin install \
      ai-engine \
      jetpack \
      rank-math-seo \
      bertha-ai \
      10web-ai-builder \
      wp2static \
      simply-static-pro \
      --activate --allow-root

# ──────────────── 10. Copy Zsh config & entrypoint ──────────────────────
COPY root.zshrc /root/.zshrc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ──────────────── 11. Entrypoint & default shell ────────────────────────
ENTRYPOINT ["/entrypoint.sh"]
CMD ["zsh"]

# ────────────────────────────────────────────────────────────────
#  🟢 Ready! This image provides a full-featured dev environment
#     with Zsh, Starship, Oh-My-Zsh, WP-CLI, and more.
# ────────────────────────────────────────────────────────────────