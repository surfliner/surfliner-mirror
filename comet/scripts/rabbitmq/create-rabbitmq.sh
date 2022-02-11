#!/bin/bash

TEMPLATE=rabbitmq.template
if [ ! -f "$TEMPLATE" ]; then
  echo "MISSING TEMPLATE $TEMPLATE"
  exit 1
fi

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

sed "s/NAME/$name/" "$TEMPLATE" > "$yml"

kubectl --kubeconfig "$kubeconfig" apply -f "$yml" -n "$namespace"
