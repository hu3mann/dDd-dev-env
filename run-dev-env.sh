#!/bin/bash
IMAGE="ghcr.io/hu3mann/ddd-dev-env:latest"

echo "Pulling latest image..."
docker pull $IMAGE

echo "Starting container..."
# Determine data path (default: parent directory of this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_DATA_PATH="$(dirname "$SCRIPT_DIR")"
DATA="${DEV_DATA_PATH:-$DEFAULT_DATA_PATH}"

docker run --rm -it \
  -v "$(pwd)":/workspace \
  -v "${DATA}":/dDd-Dev \
  "$IMAGE" zsh
