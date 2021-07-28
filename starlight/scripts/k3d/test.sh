#!/usr/bin/env sh
context="k3d-surfliner-dev"
namespace="starlight-development"
container="starlight"
pod="$(kubectl --context "$context" get pods --namespace="$namespace" "--selector=app.kubernetes.io/name=starlight" --no-headers | cut -d " " -f 1 | head -n 1)"

echo "Running tests"
kubectl --context "$context" exec -it --namespace="$namespace" "$pod" -c "$container" -- /bin/sh -c \
  "bundle exec rspec $*"
