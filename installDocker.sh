#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# CONFIG – change these two if you rename the drive or want a different 
path
SSD_LABEL="dDd-Dev"                      # your external‑drive name
PORTABLE_BREW="/Volumes/${SSD_LABEL}/brew"   # where the portable Brew 
lives
###############################################################################

BREW_BIN="${PORTABLE_BREW}/bin/brew"

# 0️⃣  Ensure Xcode Command‑Line Tools (they’re a Docker prerequisite)
if ! xcode-select -p &>/dev/null; then
  echo "Installing macOS Command Line Tools … (may pop up GUI dialog)"
  xcode-select --install
  # wait until the tools appear
  until xcode-select -p &>/dev/null; do sleep 15; done
fi

# 1️⃣  Locate or create portable Homebrew on the SSD
if [ ! -x "$BREW_BIN" ]; then
  echo "▶︎ Portable Homebrew not found – cloning to $PORTABLE_BREW …"
  mkdir -p "$PORTABLE_BREW"
  git clone --depth=1 https://github.com/Homebrew/brew "$PORTABLE_BREW"
fi

# 2️⃣  Wire this Brew into PATH for the current shell only
eval "$("$BREW_BIN" shellenv)"
echo "✓ Homebrew ready at $HOMEBREW_PREFIX"

# 3️⃣  Make sure Brew itself is up‑to‑date
brew update --quiet

# 4️⃣  Install Docker Desktop (Cask writes the .app to /Applications)
echo "▶︎ Installing Docker Desktop …"
brew install --cask docker --appdir=/Applications         # --appdir is a 
cask‑level override :contentReference[oaicite:0]{index=0}

# 5️⃣  Launch Docker the first time so it sets up its privileged helper
open -a Docker

echo "🎉 Docker Desktop installed and running."

