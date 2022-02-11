#!/bin/bash

kubeconfig=nonprod.yaml
if [ ! -f "$kubeconfig" ]; then
  echo "MISSING KUBECONFIG $kubeconfig"
  exit 1
fi

kubectl --kubeconfig "$kubeconfig" get all -n rabbitmq-system
