#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
K8S_DIR="$(dirname "$SCRIPT_DIR")"

echo "Cleaning up Kubernetes resources..."
kubectl delete -f "$K8S_DIR/base/backend-deployment.yaml"
kubectl delete -f "$K8S_DIR/base/frontend-deployment.yaml"
kubectl delete -f "$K8S_DIR/config/configmap.yaml"
kubectl delete -f "$K8S_DIR/secrets.yaml"

echo "✅ Cleanup complete!"
