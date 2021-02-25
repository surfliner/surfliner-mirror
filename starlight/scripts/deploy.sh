#!/usr/bin/env sh

namespace="starlight-development"
release=${RELEASE_NAME:=development}
values_file=${VALUES_FILE:=scripts/k3d.yaml}
registry_port=${REGISTRY_PORT:=41906}
image_repository="k3d-registry.localhost:$registry_port/starlight_web"

echo "Creating namespace for deployment..."
kubectl create namespace "$namespace"

echo "Ensuring Starlight Helm chart dependencies are installed..."
helm dep up ../charts/starlight

echo "Deployment Starlight using Helm chart into k3d cluster..."
  # --dry-run \
  # --debug \
helm upgrade \
  --timeout 30m0s \
  --atomic \
  --install \
  --namespace="$namespace" \
  --set image.repository="$image_repository" \
  --values="$values_file" \
  "$release" \
  ../charts/starlight
