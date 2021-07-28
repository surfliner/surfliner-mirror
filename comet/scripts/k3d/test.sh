#!/usr/bin/env sh

context="k3d-surfliner-dev"

pod="$(kubectl --context ${context} get pods --namespace=comet-development "--selector=app.kubernetes.io/name=hyrax" --no-headers | cut -d " " -f 1 | grep -v "worker" | head -n 1)"

kubectl --context "${context}" exec -it --namespace=comet-development "${pod}" -- /bin/sh -c "bundle exec rspec $*"
