#!/usr/bin/env sh

echo "Deleting Surfliner development k3s cluster..."
k3d cluster delete surfliner-dev
