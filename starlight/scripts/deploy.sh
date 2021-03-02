#!/usr/bin/env sh

namespace="starlight-development"
release=${RELEASE_NAME:=development}
values_file=${VALUES_FILE:=scripts/k3d.yaml}
registry_port=${REGISTRY_PORT:=41906}
image_repository="k3d-registry.localhost:$registry_port/starlight_web"

if docker image inspect "$image_repository:local" > /dev/null 2>&1; then
  echo "Starlight container image already exists in Registry, skipping build..."
else
  echo "Building and pushing Starlight container image to Registry..."
  # shellcheck disable=SC1091
  . ./scripts/build.sh
fi

if kubectl get namespaces | grep -q "starlight-development"; then
  echo "Namespace starlight-development already exists, skipping creation..."
else
  echo "Creating namespace for deployment..."
  kubectl create namespace "$namespace"
fi

if kubectl get deployments.apps -n starlight-development | grep -q "chrome"; then
  echo "Chromium container and service already installed, skipping creation..."
else
  echo "Installing Chromium into k3d cluster for running tests..."
  kubectl apply --namespace="$namespace" -f ./scripts/chromium.yaml --wait=true
fi

echo "Ensuring Starlight Helm chart dependencies are installed..."
helm dep up ../charts/starlight

echo "Deployment Starlight using Helm chart into k3d cluster..."
helm upgrade \
  --timeout 30m0s \
  --atomic \
  --install \
  --namespace="$namespace" \
  --set image.repository="$image_repository" \
  --values="$values_file" \
  "$release" \
  ../charts/starlight
