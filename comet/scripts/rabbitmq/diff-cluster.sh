#!/bin/bash

VERSION=latest
#VERSION=v1.11.0

if [ $# -ne 1 ]; then
  echo "usage: $0 <kubeconfig>"
  exit 1
fi
kubeconfig=$1

if [ ! -f "$kubeconfig" ]; then
  echo "MISSING KUBECONFIG $kubeconfig"
  exit 1
fi

# kubectl diff --help
# Output is always YAML.
# Exit status:
# 0 No differences were found.
# 1 Differences were found.
# >1 Kubectl or diff failed with an error.

kubectl --kubeconfig "$kubeconfig" diff -f https://github.com/rabbitmq/cluster-operator/releases/"$VERSION"/download/cluster-operator.yml
