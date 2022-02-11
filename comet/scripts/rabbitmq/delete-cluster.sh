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

kubectl --kubeconfig "$kubeconfig" delete -f https://github.com/rabbitmq/cluster-operator/releases/download/"$VERSION"/cluster-operator.yml
