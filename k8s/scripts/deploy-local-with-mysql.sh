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

echo "Deploying with Kubernetes MySQL..."

# Apply configurations
kubectl apply -f "$K8S_DIR/config/configmap-with-mysql.yaml"
kubectl apply -f "$K8S_DIR/secrets.yaml"
kubectl apply -f "$K8S_DIR/optional/mysql-deployment.yaml"
kubectl apply -f "$K8S_DIR/base/backend-deployment.yaml"
kubectl apply -f "$K8S_DIR/base/frontend-deployment.yaml"

echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/mysql --timeout=120s
kubectl rollout status deployment/tombolo-backend --timeout=120s
kubectl rollout status deployment/tombolo-frontend --timeout=120s

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🗄️  MySQL (internal): mysql-service:3306"
echo "🗄️  MySQL (external): localhost:30306"
echo "🌐 Frontend: http://localhost:30080"
echo "🔧 Backend API: http://localhost:30001"
echo ""
echo "To connect to MySQL from your host machine:"
echo "  mysql -h 127.0.0.1 -P 30306 -u <username> -p"
echo ""
echo "📊 To view pods: kubectl get pods"
echo "📝 To view backend logs: kubectl logs -f deployment/tombolo-backend"
echo "📝 To view MySQL logs: kubectl logs -f deployment/mysql"
echo "🗑️  To cleanup: $SCRIPT_DIR/cleanup-with-mysql.sh"
