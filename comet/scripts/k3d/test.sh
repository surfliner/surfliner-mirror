#!/usr/bin/env sh

pod="$(kubectl get pods --namespace=comet-development "--selector=app.kubernetes.io/name=hyrax" --no-headers | cut -d " " -f 1 | grep -v "worker")"

kubectl exec -it --namespace=comet-development "$pod" -- /bin/sh -c "bundle exec rspec $*"

