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
    curl -L -o /tmp/Hack.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip && \
    unzip -q /tmp/Hack.zip -d /usr/share/fonts/truetype/nerd && \
    rm /tmp/Hack.zip && fc-cache -f -v

# --- 3. Oh‑My‑Zsh without heredoc trouble ----------------------------------
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# --- starship theme ----------------------------------------------------
COPY starship.toml /root/.config/starship/starship.toml
RUN install -o ddd -g ddd -m 644 /root/.config/starship/starship.toml \
      /home/ddd/.config/starship/starship.toml
# -----------------------------------------------------------------------

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

      # --- 6. Install additional WP plugins ---------------------------------------
RUN mkdir -p /var/www && cd /var/www && \
        wp plugin install ai-engine jetpack rank-math-seo bertha-ai \
          10web-ai-builder wp2static simply-static-pro --activate --allow-root

# --- copy pre‑built Zsh config (avoids heredoc parse error) ------------
COPY root.zshrc /root/.zshrc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["zsh"]
