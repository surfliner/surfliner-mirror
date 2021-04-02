#!/usr/bin/env sh

context="k3d-surfliner-dev"
namespace="comet-development"

kubectl --context $context delete namespace $namespace
