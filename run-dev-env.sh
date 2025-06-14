#!/bin/bash
set -euo pipefail
IMAGE="ghcr.io/hu3mann/ddd-dev-env:latest"

echo "Pulling latest image..."
docker pull $IMAGE

echo "Starting container..."
# Determine data path (default: parent directory of this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_DATA_PATH="$(dirname "$SCRIPT_DIR")"
# Optional: pass host path as first argument or set DEV_DATA_PATH
DATA="${1:-${DEV_DATA_PATH:-$DEFAULT_DATA_PATH}}"

docker run --rm -it \
  -v "$(pwd)":/workspace \
  -v "${DATA}":/dDd-Dev \
  "$IMAGE" zsh
