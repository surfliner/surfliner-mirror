#!/usr/bin/env sh
# TODO: support passing rspec arguments for individual test runs, etc.
pod="$(kubectl get pods --namespace=starlight-development "--selector=app.kubernetes.io/name=starlight" --no-headers | cut -d " " -f 1)"

kubectl exec -it --namespace=starlight-development "$pod" -- /bin/sh -c "RAILS_QUEUE=inline S3_BUCKET_NAME= RAILS_ENV=test bundle exec rake"

