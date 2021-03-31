#!/usr/bin/env sh

port=${REGISTRY_PORT:=41906}
if k3d registry list | grep -q "k3d-registry.localhost"; then
  echo "Registry already exists, skipping creation..."
else
  echo "Creating Registry for container images..."
  k3d registry create registry.localhost --port "$port"
fi

if k3d cluster list | grep -q "surfliner-dev"; then
  echo "Surfliner development cluster already exists, skipping creation..."
else
  echo "Creating cluster for Surfliner development..."
  k3d cluster create surfliner-dev \
    --api-port 6550 \
    --registry-use k3d-registry.localhost:"$port" \
    --servers 1 \
    --agents 3 \
    --port 80:80@loadbalancer \
    --volume "$(pwd)":/src@all \
    --wait
fi
