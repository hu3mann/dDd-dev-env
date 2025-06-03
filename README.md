# dDd-dev-env (Portable Development Environment)

This repository provides a portable development environment that can run both locally (via Docker/GHCR)
and in GitHub Codespaces. It includes Zsh with Starship as the primary prompt, Oh My Zsh for shell
enhancements/plugins, and cloning or persisting your personal `dDd-Dev` data directory.

## Prerequisites

- Docker (for local usage)
- GitHub account & GitHub Codespaces (optional, for cloud dev)

## Local Usage (Docker)

1. Clone this repo and navigate into it:
   ```bash
   git clone https://github.com/yourusername/dDd-dev-env.git
   cd dDd-dev-env
   ```

2. (Optional) If your data directory lives elsewhere, set `DEV_DATA_PATH`:
   ```bash
   export DEV_DATA_PATH=/path/to/your/dDd-Dev
   ```
   By default, the script will mount the parent directory of this repository (i.e. your data root).

3. Run the helper script to pull the latest image and start an interactive shell:
   ```bash
   ./run-dev-env.sh
   ```

Inside the container, Zsh will load Starship and Oh My Zsh (with autosuggestions & syntax highlighting),
and will source your personal dotfiles if they exist at `$DEV_DATA_PATH/.dotfiles/.zshrc`.

## GitHub Codespaces

The Codespaces devcontainer is configured to:

- Mount a persistent Dev Container volume at `/dDd-Dev`.
- Clone your data repo on first creation if `/dDd-Dev` is empty.

### Configuring your data repo URL

Edit `.devcontainer/devcontainer.json`, replacing `YOUR_USERNAME` in `remoteEnv.DEV_DATA_REPO_URL`
with your GitHub user/org and repo name:

```diff
  "remoteEnv": {
-   "DEV_DATA_REPO_URL": "https://github.com/YOUR_USERNAME/dDd-Dev.git"
   "DEV_DATA_REPO_URL": "https://github.com/myuser/dDd-Dev.git"
  },
```

Then open this repo in VS Code and choose **Reopen in Container** (or start a new Codespace).

On first startup, the container will automatically clone your data repo into `/dDd-Dev`.
Subsequent sessions will reuse the volume to persist changes.

## Customizing the Shell

The default `/root/.zshrc` inside the container:

- Sets up the `DEV_DATA_PATH` (and switches to `/dDd-Dev` if running in Codespaces).
- Sources your personal dotfiles if available.
- Initializes the Starship prompt.
- Loads Oh My Zsh with `zsh-autosuggestions` & `zsh-syntax-highlighting`.

Feel free to adjust or extend this configuration by editing your personal dotfiles
at `$DEV_DATA_PATH/.dotfiles/.zshrc`.