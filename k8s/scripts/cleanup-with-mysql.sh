#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
K8S_DIR="$(dirname "$SCRIPT_DIR")"

echo "Cleaning up Kubernetes resources (including MySQL)..."
kubectl delete -f "$K8S_DIR/base/backend-deployment.yaml"
kubectl delete -f "$K8S_DIR/base/frontend-deployment.yaml"
kubectl delete -f "$K8S_DIR/optional/mysql-deployment.yaml"
kubectl delete -f "$K8S_DIR/config/configmap-with-mysql.yaml"
kubectl delete -f "$K8S_DIR/secrets.yaml"

echo "✅ Cleanup complete!"
echo ""
echo "Note: MySQL data is retained in PersistentVolumeClaim 'mysql-pvc'"
echo "To delete data: kubectl delete pvc mysql-pvc"
