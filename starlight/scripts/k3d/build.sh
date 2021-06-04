#!/usr/bin/env sh
registry_port=${REGISTRY_PORT:=41906}
git_sha="$(git rev-parse HEAD)"
image_tag="k3d-registry.localhost:$registry_port/starlight_web:$git_sha"

echo "Building Starlight image..."
docker build -t "$image_tag" -f Dockerfile ..

echo "Pushing Starlight image to local registry..."
docker push "$image_tag"
