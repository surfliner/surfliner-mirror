#!/usr/bin/env sh
# Get dynamically assigned registry port via docker ps
# registry_port=$(docker ps -f name=k3d-starlight-registry --format="{{.Ports}}" | cut -d ":" -f 2 | cut -d "-" -f 1)
registry_port=${REGISTRY_PORT:=41906}
image_tag="k3d-registry.localhost:$registry_port/starlight_web:local"

echo "Building Starlight image..."
pwd
docker build -t "$image_tag" -f Dockerfile ..

echo "Pushing Starlight image to local registry..."
docker push "$image_tag"
