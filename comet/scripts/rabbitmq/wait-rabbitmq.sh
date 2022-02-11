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

kubectl --kubeconfig "$kubeconfig" get -f "$yml" -n "$namespace" -o json | jq '.status.conditions[] | select(.type=="AllReplicasReady" and .status=="True")'

#######################################
#kubectl --kubeconfig nonprod.yaml get rabbitmqcluster.rabbitmq.com/surfliner -o json | jq '.status.conditions[] | select(.type=="AllReplicasReady" and .status=="True")'

#kubectl --kubeconfig nonprod.yaml get rabbitmqcluster.rabbitmq.com/surfliner -o json | jq '.status.conditions[] | .type,.status'

#kubectl --kubeconfig nonprod.yaml get rabbitmqcluster.rabbitmq.com/surfliner -o json | jq '.status.conditions["type": "AllReplicasReady"]'

#kubectl --kubeconfig nonprod.yaml wait --for=condition=ready rabbitmqcluster surfliner
