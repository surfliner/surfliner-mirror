#!/bin/bash

namespace="--all-namespaces"

if [ $# -ne 2 ]; then
	echo "usage: $0 <kubeconfig> <namespace|all>"
	exit 1
fi
kubeconfig=$1
if [ "$2" != "all" ]; then
  namespace="-n $2"
fi

if [ ! -f "$kubeconfig" ]; then
  echo "MISSING KUBECONFIG $kubeconfig"
  exit 1
fi

kubectl --kubeconfig "$kubeconfig" get rabbitmqclusters.rabbitmq.com "$namespace"
