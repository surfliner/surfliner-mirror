#!/usr/bin/env sh
registry_port=${REGISTRY_PORT:=41906}
image_tag="k3d-registry.localhost:$registry_port/comet_web:local"

echo "Building Comet image..."
docker build -t "$image_tag" -f Dockerfile .

echo "Pushing Comet image to local registry..."
docker push "$image_tag"
