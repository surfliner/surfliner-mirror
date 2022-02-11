#!/bin/bash

if [ $# -ne 3 ]; then
  echo "usage: $0 <kubeconfig> <namespace> <rabbitmq name>"
  exit 1
fi
kubeconfig=$1
namespace=$2
name=$3

if [ ! -f "$kubeconfig" ]; then
  echo "MISSING KUBECONFIG $kubeconfig"
  exit 1
fi

yml=rabbitmq-"$namespace"-"$name".yml
if [ ! -f "$yml" ]; then
  echo "MISSING YML $yml"
  exit 1
fi

# kubectl diff --help
# Output is always YAML.
# Exit status:
# 0 No differences were found.
# 1 Differences were found.
# >1 Kubectl or diff failed with an error.

kubectl --kubeconfig "$kubeconfig" diff -f "$yml" -n "$namespace"
