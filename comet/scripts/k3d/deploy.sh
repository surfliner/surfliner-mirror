#!/usr/bin/env sh

context="k3d-surfliner-dev"
namespace="comet-development"
release=${RELEASE_NAME:=comet}
values_file=${VALUES_FILE:=../charts/snippets/comet/k3d.yaml}
registry_port=${REGISTRY_PORT:=41906}

git_sha="$(git rev-parse HEAD)"
image_repository="k3d-registry.localhost:$registry_port/comet_web"
worker_image_repository="k3d-registry.localhost:$registry_port/comet_worker_web"

if docker image inspect "$image_repository:${git_sha}" > /dev/null 2>&1; then
  echo "Comet container image already exists in Registry, skipping build..."
else
  echo "Building and pushing Comet container image to Registry..."
  # shellcheck disable=SC1091
  . ./scripts/k3d/build.sh
fi

if kubectl --context $context get namespaces | grep -q 'surfliner-utilities'; then
  echo "Namespace surfliner-utilities already exists, skipping creation..."
else
  echo "Creating surfliner-utilities namespace..."
  kubectl --context $context create namespace surfliner-utilities
fi

if kubectl --context $context get namespaces | grep -q $namespace; then
  echo "Namespace $namespace already exists, skipping creation..."
else
  echo "Creating namespace for deployment..."
  kubectl --context $context create namespace "$namespace"
fi

if kubectl --context $context get deployments.apps -n surfliner-utilities | grep -q "chrome"; then
  echo "Chromium container and service already installed, skipping creation..."
else
  echo "Installing Chromium into k3d cluster for running tests..."
  kubectl --context $context apply --namespace=surfliner-utilities -f ../k3d/chromium.yaml --wait=true
fi

HELM_EXPERIMENTAL_OCI=1 \
  helm pull oci://ghcr.io/samvera/hyrax/hyrax-helm \
    --version 0.21.1 \
    --untar \
    --untardir charts

echo "Deploying Hyrax using Helm chart into k3d cluster..."
helm upgrade \
  --install \
  --kube-context="$context" \
  --namespace="$namespace" \
  --set image.repository="$image_repository" \
  --set image.tag="${git_sha}" \
  --set worker.image.repository="$worker_image_repository" \
  --set worker.image.tag="${git_sha}" \
  --values="$values_file" \
  ${LOCAL_VALUES_FILE+--values="$LOCAL_VALUES_FILE"} \
  "$release" \
  ./charts/hyrax
