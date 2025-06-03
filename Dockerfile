FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl zsh git nano wget unzip fonts-powerline \
    gnupg software-properties-common python3 python3-pip \
    nodejs npm ripgrep fzf bat httpie \
    zsh-autosuggestions zsh-syntax-highlighting \
    && apt-get clean

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Nerd Fonts (Fira Code)
RUN mkdir -p /usr/share/fonts/truetype/nerd && \
    cd /usr/share/fonts/truetype/nerd && \
    curl -fLo "FiraCodeNerdFont-Regular.ttf" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip && unzip FiraCode.zip && rm FiraCode.zip

SHELL ["/bin/zsh", "-c"]
