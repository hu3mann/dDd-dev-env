# dDd-dev-env (Portable Development Environment)

This repository defines a portable development container image that you can use:
1. **Locally** via Docker / GitHub Container Registry (GHCR)
2. **In GitHub Codespaces** via the built‑in devcontainer support

It boots Debian with Zsh, Starship as the primary prompt, Oh My Zsh plugins, and auto‑sources your
private dotfiles from an external "dDd‑Dev" data directory.

## Prerequisites

- **Docker** 20.10 or newer (local usage)
- (Optional) **GitHub account & Codespaces** for cloud dev
- (Optional) **GitHub PAT** with `write:packages` (if you push your image to GHCR)
- **Private dotfiles** repo (added as a submodule under your data root at `.dotfiles/`) containing:
  - `~/.zshrc`, other shell configs
  - `.docker/config.json` with GHCR creds

> **Security note:** Keep your dotfiles repo private so credentials never leak.

## SSD / DEV_DATA_PATH Layout

Your projects, dotfiles, and VS Code data should live under a persistent "data root" (SSD/host directory).
By default the helper script mounts this repo's parent directory into the container as `/dDd-Dev`. Example:

```text
/Volumes/SSD-Data
├── .dotfiles           # submodule → your private dotfiles repo
├── code-portable-data  # VS Code settings & extensions
└── Projects
    ├── dDd-dev-env     # this repo
    ├── project-A
    └── project-B
```

## Local Usage (Docker)

```bash
# 1. Clone & cd into this repo
git clone git@github.com:hu3mann/dDd-dev-env.git
cd dDd-dev-env

# 2. (Optional) Login to GHCR for pulling/pushing
echo "$GHCR_PAT" \
  | docker login ghcr.io --username hu3mann --password-stdin

# 3. (Optional) Override data root if outside parent directory
export DEV_DATA_PATH=/Volumes/SSD-Data

# 4. Launch the container (mounts your data root → /dDd-Dev)
./run-dev-env.sh
```

Inside the container, Zsh will:
- Source `$DEV_DATA_PATH/.dotfiles/.zshrc`
- Initialize Starship prompt
- Load Oh My Zsh with `zsh-autosuggestions` & `zsh-syntax-highlighting`

Your `code-portable-data/` and `Projects/…` appear under `/dDd-Dev`.

## Building & Publishing the Image (GHCR)

On each push to `main`, the included GitHub Actions workflow
(`.github/workflows/build-and-push.yml`) will build and push:
```
ghcr.io/hu3mann/ddd-dev-env:latest
```

### Manual (Local) build & push

```bash
# from repo root
docker build -t ghcr.io/hu3mann/ddd-dev-env:latest .
docker push ghcr.io/hu3mann/ddd-dev-env:latest
```

## GitHub Codespaces

Open this repo in a new Codespace or VS Code Remote-Container. The devcontainer will:
1. Mount a persistent volume at `/dDd-Dev`
2. On first startup, clone your data repo into `/dDd-Dev` if the volume is empty.
   This uses `[ "$(ls -A /dDd-Dev 2>/dev/null)" ] || git clone $DEV_DATA_REPO_URL /dDd-Dev`.

### Configure your data repo URL

In `.devcontainer/devcontainer.json`, set `DEV_DATA_REPO_URL` to your data‑repo:

```jsonc
"remoteEnv": {
  "DEV_DATA_REPO_URL": "https://github.com/hu3mann/dDd-Dev.git"
},
```

## Managing Your Dotfiles Submodule

Your private dotfiles repo (`git@github.com:hu3mann/dotfiles.git`) holds your shell config and GHCR creds.
To link it under your data root:

```bash
# one‑time init (if not already)
git submodule add git@github.com:hu3mann/dotfiles.git .dotfiles
git submodule update --init --recursive
```

When you change your dotfiles:

```bash
cd .dotfiles && git add . && git commit -m "chore: update dotfiles" && git push
cd ..
git add .dotfiles && git commit -m "chore: bump dotfiles submodule" && git push
```

## Switching Between Projects

Every project under `Projects/…` can use this same base image. Simply open its folder in VS Code and
**Reopen in Container**. For a multi‑root workspace that loads all your repos in one window, move
`.devcontainer/` up to the data‑root and create a `.code-workspace` listing each `Projects/<repo>`.
