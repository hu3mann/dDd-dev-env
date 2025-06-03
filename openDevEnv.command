#!/bin/bash

PROJECT_PATH="/Volumes/dDd-Dev/Projects/my-app"
VSCODE_APP="/Volumes/dDd-Dev/VSCode/Visual Studio Code.app"

# Bring Terminal to front
osascript -e 'tell application "Terminal" to activate'

echo "📂 Opening project: $PROJECT_PATH"
echo "💻 VS Code: $VSCODE_APP"

open -a "$VSCODE_APP" --args "$PROJECT_PATH"

echo "✅ Done! Dev container should prompt automatically in VS Code."
echo "Press ENTER to close this window."
read -r

