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

kubectl --kubeconfig "$kubeconfig" delete rabbitmqclusters.rabbitmq.com "$name" -n "$namespace"
