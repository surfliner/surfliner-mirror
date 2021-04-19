#!/usr/bin/env sh

port=${REGISTRY_PORT:=41906}
if k3d registry list | grep -q "k3d-registry.localhost"; then
  echo "Registry already exists, skipping creation..."
else
  echo "Creating Registry for container images..."
  k3d registry create registry.localhost --port "$port"
fi
