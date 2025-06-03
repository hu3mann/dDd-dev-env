#!/bin/zsh

# Start the agent if not already running
eval "$(ssh-agent -s)" > /dev/null

# Add your key (from external drive or container)
ssh-add /Volumes/dDd-Dev/.ssh/id_ed25519 > /dev/null 2>&1 && echo "✅ SSH 
key added." || echo "⚠️ Failed to add SSH key."

# Optional: test connection
ssh -T git@github.com
