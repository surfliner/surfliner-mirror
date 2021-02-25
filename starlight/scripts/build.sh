#!/usr/bin/env sh
registry_port=${REGISTRY_PORT:=41906}
image_tag="k3d-registry.localhost:$registry_port/starlight_web:local"

echo "Building Starlight image..."
docker build -t "$image_tag" -f Dockerfile ..

echo "Pushing Starlight image to local registry..."
docker push "$image_tag"
