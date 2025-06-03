#!/bin/bash
IMAGE="ghcr.io/YOUR_USERNAME/dDd-dev-env:latest"

echo "Pulling latest image..."
docker pull $IMAGE

echo "Starting container..."
docker run --rm -it \
  -v $(pwd):/workspace \
  -v /Volumes/dDd-Dev:/dDd-Dev \
  $IMAGE zsh
