#!/usr/bin/env sh

namespace="comet-development"
release=${RELEASE_NAME:=comet}
values_file=${VALUES_FILE:=scripts/k3d.yaml}
registry_port=${REGISTRY_PORT:=41906}
image_repository="k3d-registry.localhost:$registry_port/comet_web"

if docker image inspect "$image_repository:local" > /dev/null 2>&1; then
  echo "Comet container image already exists in Registry, skipping build..."
else
  echo "Building and pushing Comet container image to Registry..."
  # shellcheck disable=SC1091
  . ./scripts/build.sh
fi

echo "Ensuring kubectl uses k3d-surfliner-dev context/cluster..."
kubectl config use-context k3d-surfliner-dev

if kubectl get namespaces | grep -q $namespace; then
  echo "Namespace $namespace already exists, skipping creation..."
else
  echo "Creating namespace for deployment..."
  kubectl create namespace "$namespace"
fi

if kubectl get deployments.apps -n $namespace | grep -q "chrome"; then
  echo "Chromium container and service already installed, skipping creation..."
else
  echo "Installing Chromium into k3d cluster for running tests..."
  kubectl apply --namespace="surfliner-utilities" -f ../k3d/chromium.yaml --wait=true
fi

helm dep up ../../hyrax/chart/hyrax

echo "Deploying Hyrax using Helm chart into k3d cluster..."
helm upgrade \
  --install \
  --namespace="$namespace" \
  --set image.repository="$image_repository" \
  --set worker.image.repository="$image_repository" \
  --values="$values_file" \
  "$release" \
  ../../hyrax/chart/hyrax
