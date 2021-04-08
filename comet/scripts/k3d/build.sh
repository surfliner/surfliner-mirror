#!/usr/bin/env sh
registry_port=${REGISTRY_PORT:=41906}

git_sha="$(git rev-parse HEAD)"
image_tag="k3d-registry.localhost:$registry_port/comet_web:${git_sha}"
worker_image_tag="k3d-registry.localhost:$registry_port/comet_worker_web:${git_sha}"

echo "Building Comet image..."
docker build -t "$image_tag" --target "comet" -f Dockerfile ..

echo "Pushing Comet image to local registry..."
docker push "$image_tag"

echo "Building Comet worker image..."
docker build -t "$worker_image_tag" --target "comet-worker" -f Dockerfile ..

echo "Pushing Comet worker image to local registry..."
docker push "$worker_image_tag"
