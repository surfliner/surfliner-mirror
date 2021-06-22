#!/usr/bin/env sh
registry_port=${REGISTRY_PORT:=41906}
git_sha="$(git rev-parse HEAD)"
image_tag="k3d-registry.localhost:$registry_port/surfliner-util:$git_sha"

echo "Building util image..."
docker build -t "$image_tag" -f ../util/Dockerfile ..

echo "Pushing util image to local registry..."
docker push "$image_tag"
