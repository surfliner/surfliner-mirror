#!/bin/bash

if [ $# -ne 1 ]; then
  echo "usage: $0 <kubeconfig>"
  exit 1
fi
kubeconfig=$1

if [ ! -f "$kubeconfig" ]; then
  echo "MISSING KUBECONFIG $kubeconfig"
  exit 1
fi

kubectl --kubeconfig "$kubeconfig" rollout status deployment/rabbitmq-cluster-operator -n rabbitmq-system
