#!/usr/bin/env sh

port=${REGISTRY_PORT:=41906}
echo "Creating Registry for container images..."
k3d registry create registry.localhost --port "$port"
echo "Creating k3s cluster for Starlight..."
k3d cluster create starlight \
  --api-port 6550 \
  --registry-use k3d-registry.localhost:"$port" \
  --servers 1 \
  --agents 3 \
  --port 80:80@loadbalancer \
  --volume "$(pwd)":/src@all \
  --wait
