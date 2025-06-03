#!/bin/bash
IMAGE="ghcr.io/YOUR_USERNAME/dDd-dev-env:latest"

echo "Pulling latest image..."
docker pull $IMAGE

echo "Starting container..."
DATA="${DEV_DATA_PATH:-/Volumes/dDd-Dev}"
docker run --rm -it \
  -v "$(pwd)":/workspace \
  -v "${DATA}":/dDd-Dev \
  "${IMAGE}" zsh
