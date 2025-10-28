#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
K8S_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$K8S_DIR")"

echo "Building Docker images..."

# Build backend image
cd "$PROJECT_ROOT/Tombolo/server"
docker build -t tombolo-backend:latest .

# Build frontend image
cd "$PROJECT_ROOT/Tombolo/client-reactjs"
docker build -t tombolo-frontend:latest .

echo "Applying Kubernetes manifests..."

# Apply configurations
kubectl apply -f "$K8S_DIR/config/configmap.yaml"
kubectl apply -f "$K8S_DIR/secrets.yaml"
kubectl apply -f "$K8S_DIR/base/backend-deployment.yaml"
kubectl apply -f "$K8S_DIR/base/frontend-deployment.yaml"

echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/tombolo-backend --timeout=120s
kubectl rollout status deployment/tombolo-frontend --timeout=120s

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Frontend: http://localhost:30080"
echo "🔧 Backend API: http://localhost:30001"
echo ""
echo "📊 To view pods: kubectl get pods"
echo "📝 To view logs: kubectl logs -f deployment/tombolo-backend"
echo "🗑️  To cleanup: $SCRIPT_DIR/cleanup.sh"
