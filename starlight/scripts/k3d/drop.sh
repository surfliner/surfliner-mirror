#!/usr/bin/env sh

context="k3d-surfliner-dev"
namespace="starlight-development"

kubectl --context $context delete namespace $namespace
