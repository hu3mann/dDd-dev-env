
#!/bin/bash

# Bring Terminal to front
osascript -e 'tell application "Terminal" to activate'

echo "🛠️  Installing Docker Desktop via portable Homebrew…"

SSD_LABEL="dDd-Dev"
PORTABLE_BREW="/Volumes/${SSD_LABEL}/brew"
BREW_BIN="${PORTABLE_BREW}/bin/brew"

# Ensure CLT (required by Brew & Docker)
if ! xcode-select -p &>/dev/null; then
  echo "📦 Installing macOS Command Line Tools (wait for prompt)…"
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 10; done
fi

# Clone Brew if not present
if [ ! -x "$BREW_BIN" ]; then
  echo "🍺 Installing portable Homebrew at $PORTABLE_BREW"
  mkdir -p "$PORTABLE_BREW"
  git clone --depth=1 https://github.com/Homebrew/brew "$PORTABLE_BREW"
fi

eval "$("$BREW_BIN" shellenv)"

echo "⬇️  Updating Homebrew"
brew update --quiet

echo "🐳 Installing Docker Desktop…"
brew install --cask docker --appdir=/Applications

echo "🚀 Launching Docker"
open -a Docker

echo ""
echo "✅ Docker is now installed and running!"
echo "Press ENTER to close this window."
read -r

