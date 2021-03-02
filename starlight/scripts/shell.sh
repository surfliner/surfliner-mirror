#!/usr/bin/env sh
pod="$(kubectl get pods --namespace=starlight-development "--selector=app.kubernetes.io/name=starlight" --no-headers | cut -d " " -f 1)"

kubectl exec -it --namespace=starlight-development "$pod" -- /bin/sh

