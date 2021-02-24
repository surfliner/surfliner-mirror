#!/usr/bin/env sh

echo "Deleting k3s cluster for Starlight..."
k3d cluster delete starlight
