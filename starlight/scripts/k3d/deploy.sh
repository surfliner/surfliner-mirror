#!/usr/bin/env sh

context="k3d-surfliner-dev"
namespace="starlight-development"
release=${RELEASE_NAME:=development}
values_file=${VALUES_FILE:=scripts/k3d/k3d.yaml}
registry_port=${REGISTRY_PORT:=41906}
image_repository="k3d-registry.localhost:$registry_port/starlight_web"
util_image_repository="k3d-registry.localhost:$registry_port/surfliner-util"
git_sha="$(git rev-parse HEAD)"

if docker image inspect "$image_repository:$git_sha" > /dev/null 2>&1; then
  echo "Starlight container image already exists in Registry, skipping build..."
else
  echo "Building and pushing Starlight container image to Registry..."
  # shellcheck disable=SC1091
  . ./scripts/k3d/build.sh
fi

if docker image inspect "$image_repository:$git_sha" > /dev/null 2>&1; then
  echo "Util container image already exists in Registry, skipping build..."
else
  echo "Building and pushing util container image to Registry..."
  # shellcheck disable=SC1091
  . ./scripts/k3d/build-util.sh
fi

if kubectl --context $context get namespaces | grep -q "starlight-development"; then
  echo "Namespace starlight-development already exists, skipping creation..."
else
  echo "Creating namespace for deployment..."
  kubectl --context $context create namespace "$namespace"
fi

if kubectl --context $context get deployments.apps -n starlight-development | grep -q "chrome"; then
  echo "Chromium container and service already installed, skipping creation..."
else
  echo "Installing Chromium into k3d cluster for running tests..."
  kubectl --context $context apply --namespace="$namespace" -f ./scripts/k3d/chromium.yaml --wait=true
fi

echo "Ensuring Starlight Helm chart dependencies are installed..."
helm dep up ../charts/starlight

echo "Deployment Starlight using Helm chart into k3d cluster..."
helm upgrade \
  --timeout 30m0s \
  --atomic \
  --install \
  --kube-context="$context" \
  --namespace="$namespace" \
  --set image.repository="$image_repository" \
  --set image.tag="${git_sha}" \
  --set extraInitContainers[0].image="${util_image_repository}:${git_sha}" \
  --values="$values_file" \
  ${LOCAL_VALUES_FILE+--values="$LOCAL_VALUES_FILE"} \
  "$release" \
  ../charts/starlight
