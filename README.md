# dDd-dev-env: Eye-Candy Dev Container with aharoJ Starship Theme

This is a **modern Docker development container** featuring:
- Zsh + Oh My Zsh, autosuggestions, syntax highlighting, and fzf fuzzy search
- **Starship prompt** themed and modularized (using aharoJ’s high-contrast config)
- [WordPress CLI + AI plugins pre-installed](#wordpress-ai-plugins)
- Auto-cloning of your private dotfiles if not mounted
- GitHub Actions compatible

## ✨ Prompt Features (aharoJ Eye Candy)

This dev environment uses Starship with **imported module configs** for maximum visual clarity:

| Module      | What it does                                             |
|-------------|---------------------------------------------------------|
| Directory   | Shows pretty, icon-enhanced working directory           |
| Git         | Vivid branch/status display, ahead/behind, icons        |
| Languages   | Detects & shows Node, Python, PHP, etc. version info    |
| Battery     | Status shown (for laptops)                              |
| Time        | Clock in prompt                                         |
| Cmd         | Time each command took to run                           |
| Name        | Shows username/host info                                |

**Prompt modules are managed via modular TOML configs in `/scripts/active/` and `/scripts/non-active/`, then imported in `starship.toml` using the [Starship import system](https://starship.rs/config/#importing-other-configs).**

### Example prompt

(See `/z/` for more screenshots, if desired.)

## 🐳 Quick Start

1. **Clone this repo:**
   ```sh
   git clone https://github.com/yourname/dDd-dev-env.git
   cd dDd-dev-env
   ```

2. **Copy your private dotfiles repo to `/dDd-Dev/.dotfiles` on your machine**  
   (Or let the container clone it for you on first run.)

3. **Build and run:**
   ```sh
   docker build -t ddd-dev .
   # pass your host path as an argument or set DEV_DATA_PATH
   ./run-dev-env.sh /path/to/drive
   ```

   *If `/dDd-Dev/.dotfiles` is missing, the container will auto-clone from your private repo.*

## ⚙️ Enabling/Disabling Prompt Modules

- To add or remove features, **edit `starship.toml` and modify the `import` array**:
  ```toml
  import = [
    "scripts/active/directory.toml",
    "scripts/active/git.toml",
    "scripts/active/languages.toml",
    "scripts/non-active/time.toml",        # comment this to hide the clock
    "scripts/non-active/battery.toml",     # comment this if not on a laptop
    "scripts/non-active/cmd.toml",
    "scripts/non-active/name.toml"
  ]
  ```
- Or directly edit the individual `*.toml` files for custom tweaks.

## 📝 Customization

- Zsh is pre-configured with Oh My Zsh, [autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), and [fzf](https://github.com/junegunn/fzf) fuzzy search.
- Starship prompt is themed for vibrant, readable output with icons (Nerd Font required—preinstalled FiraCode Nerd).
- Your own dotfiles are loaded automatically if present in `/dDd-Dev/.dotfiles/.zshrc`.

## 🛠️ WordPress AI Plugins

- Preinstalled with WP-CLI and the following AI/static plugins: AI Engine, Jetpack AI, Rank Math AI, Bertha AI, 10Web AI, WP2Static, Simply Static Pro.
- See `Dockerfile` for install commands and upgrade instructions.

## 🚀 Screenshots

Screenshots of the prompt and its modules are in `/z/` if you add them.

---

### Attribution

- Starship config and modular setup based on [aharoJ/starship-config](https://github.com/aharoJ/starship-config)
- Starship prompt: [starship.rs](https://starship.rs/)
- Zsh, Oh My Zsh, and plugins: see their respective repos

---
