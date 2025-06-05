# dDd-dev-env 🐚✨
**The Portable, Pleasure-First Development Environment**

> _“Code hard. Play harder. Boot anywhere.”_

Welcome to **dDd-dev-env**, the all-in-one dev container image and helper toolkit that lets you sling code from an external SSD, a Codespace, or a fresh Mac you just seduced at Starbucks. Everything lives in one Git repo—and one portable data directory—so your *entire* workflow travels with you like a trusty black latex catsuit.

---

## 1️⃣ Why You’ll Love It

| Feature                        | What It Means (in Plain English)                                         |
|--------------------------------|---------------------------------------------------------------------------|
| **Debian 12 Base**             | Stable, trim, widely supported.                                           |
| **Zsh + Oh My Zsh**            | Autocompletion so slick it feels illegal.                                 |
| **Starship Prompt**            | Sexy, minimal, Nerd-Font-powered prompt.                                   |
| **Fira Code Nerd Font Baked In**| Those pretty Dev Icons “just work” inside the container.                    |
| **CLI-Tool Buffet**            | `git`, `gh`, `jq`, `ripgrep`, `fzf`, `bat`, `httpie`, Node LTS, Python 3, Helix, et al. |
| **Dotfiles Auto-Sourcing**     | Mount any directory as `/dDd-Dev`; the container slurps up `/dDd-Dev/.dotfiles/.zshrc` automatically. |
| **Runs Local *or* in GitHub Codespaces** | Same Dockerfile, zero surprises.                                     |
| **Ready-to-Push GHCR Image**   | CI workflow builds & publishes `ghcr.io/<owner>/ddd-dev-env:latest`.       |

---

## 2️⃣ Repo Layout (Bird’s-Eye)

```text
dDd-dev-env/                 # ← this repo
├─ Dockerfile                # the actual container recipe
├─ run-dev-env.sh            # pull & run image locally
├─ docker-login-ghcr.sh      # secure GHCR login helper
├─ LaunchNewStarship.sh      # macOS “new-machine spin-up” script
├─ installDocker.{sh,command}# Docker Desktop bootstrap (portable Homebrew)
├─ openDevEnv.command # macOS one-click VS Code launcher
├─ .devcontainer/ # Codespaces config
└─ .github/workflows/ # CI to build & push to GHCR


Your **persistent data** lives *outside* the repo, usually on an external volume:

```text
/Volumes/SSD-Data               (≘ $DEV_DATA_PATH or /dDd-Dev)
├─ .dotfiles/                   # private dotfiles repo (Zsh, Starship, Git, Nano, etc.)
│   └─ …                        # (See dotfiles/README.md)
├─ code-portable-data/          # VS Code portable profile (optional)
└─ Projects/
   ├─ dDd-dev-env/              # ← this repo lives here
   └─ your-other-projects/
```

---

## 3️⃣ Quick-Start (Local Docker)

```bash
# 1. Clone the repo next to your other projects
git clone https://github.com/hu3mann/dDd-dev-env.git \
      /Volumes/SSD-Data/Projects/dDd-dev-env
cd /Volumes/SSD-Data/Projects/dDd-dev-env

# 2. (One-time) log in to GHCR so Docker can pull the image
./docker-login-ghcr.sh        # reads token from ~/.dotfiles/.docker/config.json

# 3. Fire up the container, mounting the whole SSD as /dDd-Dev
./run-dev-env.sh
# → drops you into /workspace (repo root) with slick Starship prompt
Tips:

If you change $DEV_DATA_PATH (e.g., to a different external SSD), just re-export that env var before running.
To use a local Docker image instead of GHCR:
docker build -t ddd-dev-env:local .
docker run -it \
  -v "/Volumes/SSD-Data:/dDd-Dev:rw" \
  -v "$PWD:/workspace:rw" \
  -w "/workspace" \
  ddd-dev-env:local
4️⃣ New-Mac Spin-Up (Apple Silicon)

Got a virgin Mac? 🎉  
Plug in the SSD and run:

```bash
/Volumes/SSD-Data/Projects/dDd-dev-env/LaunchNewStarship.sh
```

What it does (fully automated):

- Installs Homebrew (portable, on the SSD if you like).
- Installs Docker Desktop, VS Code (portable mode with its own code-portable-data).
- Installs Fira Code Nerd Font system-wide.
- Installs Starship, Oh My Zsh, plugins, and links your dotfiles.
- Extracts your GHCR Personal Access Token from $DEV_DATA_PATH/.dotfiles/.docker/config.json and logs Docker in.
- Leaves you with a “Ready-to-play” message. Launch Terminal, type docker ps, grin.

---

## 5️⃣ Codespaces

- Press the “Code → Codespaces → New” button on GitHub.
- First run builds the image from the Dockerfile.
- The postCreateCommand clones your private data repo (URL held in DEV_DATA_REPO_URL) into /dDd-Dev.
- Nerd font and Zsh prompt are ready out-of-the-box in the Codespaces terminal.

Tip: Store any private PATs as Codespaces secrets so CI can still push to GHCR.

---

## 6️⃣ Building & Publishing the Image Yourself

Locally:

```bash
docker build -t ghcr.io/<you>/ddd-dev-env:latest .
echo "$GHCR_PAT" | docker login ghcr.io -u <you> --password-stdin
docker push ghcr.io/<you>/ddd-dev-env:latest
```

CI:  
The workflow in .github/workflows/build-and-push.yml does exactly that on every push to main.

---

## 7️⃣ Script Cheat-Sheet

| Script                | Use-Case                                                      | Notes                                      |
|-----------------------|--------------------------------------------------------------|--------------------------------------------|
| run-dev-env.sh        | Pulls latest image & docker run … with volume mounts         | Override data path by env-var.             |
| docker-login-ghcr.sh  | Reads PAT from ~/.docker/config.json or $DEV_DATA_PATH/.dotfiles/.docker/config.json, decodes, logs in. | No token in bash history. |
| LaunchNewStarship.sh  | Turn a factory-fresh Mac into a fully armed battle station.  | Config block at top for path overrides.    |
| installDocker.(sh/command) | Offline/portable install of Docker Desktop via Homebrew on external disk. | Useful on company-managed Macs. |
| openDevEnv.command    | Double-click to open VS Code (portable mode) pointing at your project path. | Uses AppleScript to bring Terminal to front for logs. |

---

## 8️⃣ Environment Variables

| Variable      | Default                                 | Purpose                                                         |
|---------------|-----------------------------------------|-----------------------------------------------------------------|
| DEV_DATA_PATH | /dDd-Dev (in container) or ~/SSD-Data   | Host folder (external SSD) mounted as /dDd-Dev; holds your dotfiles/ and projects. |
| GHCR_PAT      | Derived at runtime by docker-login-ghcr.sh | Docker personal access token for GitHub Container Registry.     |
| CODESPACES    | Set automatically by GitHub when in Codespaces | Signals “we’re in a dev container,” used by scripts to handle mounts or skip steps. |

---

## 9️⃣ Troubleshooting

| Symptom                        | Fix                                                                 |
|--------------------------------|---------------------------------------------------------------------|
| Font glyphs show as squares    | Set your terminal font (iTerm2, WezTerm, Kitty, Alacritty) to Fira Code Nerd Font. |
| docker pull fails with 401     | Re-run ./docker-login-ghcr.sh. Ensure GHCR PAT is valid and not revoked. |
| Host folder not mounted in container | Confirm $DEV_DATA_PATH on host matches the -v argument in run-dev-env.sh. |
| Codespaces volume mount not permitted | Codespaces uses a named volume; it’s normal for $DEV_DATA_PATH to be a cloned repo, not a host mount. |
| Starship prompt looks broken   | Ensure ~/.config/starship.toml exists and is valid TOML. See starship docs. |

---