#!/usr/bin/env sh
context="k3d-surfliner-dev"
namespace="starlight-development"
pod="$(kubectl --context "$context" get pods --namespace="$namespace" "--selector=app.kubernetes.io/name=starlight" --no-headers | cut -d " " -f 1)"

kubectl --context "$context" exec -it --namespace="$namespace" "$pod" -- /bin/sh -c "bundle exec rspec $*"

