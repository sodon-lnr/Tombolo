# Tombolo Kubernetes Deployment

This directory contains Kubernetes manifests for deploying the Tombolo application locally.

## Directory Structure

```
k8s/
├── base/                          # Core deployments (always used)
│   ├── backend-deployment.yaml    # Node.js backend
│   ├── frontend-deployment.yaml   # React frontend
│   └── secrets.yaml.example       # Template for secrets
├── config/                        # Configuration variants
│   ├── configmap-local.yaml       # Uses host MySQL (default)
│   └── configmap-with-mysql.yaml  # Uses Kubernetes MySQL
├── optional/                      # Optional components
│   └── mysql-deployment.yaml      # MySQL database in K8s
├── scripts/                       # Deployment automation
│   ├── deploy-local.sh            # Deploy with host MySQL
│   ├── deploy-local-with-mysql.sh # Deploy with K8s MySQL
│   ├── cleanup.sh                 # Cleanup (host MySQL mode)
│   └── cleanup-with-mysql.sh      # Cleanup (K8s MySQL mode)
├── secrets.yaml                   # Your actual secrets (gitignored)
└── README.md                      # This file
```

## Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl configured
- MySQL 8.0 running locally (for default setup) OR use Kubernetes MySQL option

## Setup

### 1. Create Secrets

Copy the example and update with your values:

```bash
cp secrets.yaml.example secrets.yaml
# Edit secrets.yaml with your actual credentials
```

### 2. Choose Your Deployment Option

#### Option A: Use Local MySQL (Default)

Uses your existing MySQL running on your host machine.

```bash
# Run from anywhere in the project
./k8s/scripts/deploy-local.sh

# Or from the scripts directory
cd k8s/scripts
./deploy-local.sh
```

**Access Points:**

- Frontend: http://localhost:30080
- Backend: http://localhost:30001
- MySQL: localhost:3306 (your existing instance)

#### Option B: Deploy MySQL in Kubernetes

Runs MySQL inside Kubernetes (good for isolated testing).

```bash
# Run from anywhere in the project
./k8s/scripts/deploy-local-with-mysql.sh

# Or from the scripts directory
cd k8s/scripts
./deploy-local-with-mysql.sh
```

**Access Points:**

- Frontend: http://localhost:30080
- Backend: http://localhost:30001
- MySQL: localhost:30306 (Kubernetes instance)

**Note:** External port is 30306 to avoid conflicts with local MySQL on 3306.

## Management Commands

```bash
# View all pods
kubectl get pods

# View backend logs
kubectl logs -f deployment/tombolo-backend

# View frontend logs
kubectl logs -f deployment/tombolo-frontend

# View MySQL logs (if using K8s MySQL)
kubectl logs -f deployment/mysql

# Restart a deployment
kubectl rollout restart deployment/tombolo-backend

# Scale replicas
kubectl scale deployment tombolo-backend --replicas=3
```

## Cleanup

### If using local MySQL:

```bash
# Run from anywhere
./k8s/scripts/cleanup.sh
```

### If using Kubernetes MySQL:

```bash
# Run from anywhere
./k8s/scripts/cleanup-with-mysql.sh
./cleanup-with-mysql.sh
```

**Note:** MySQL data persists in a PersistentVolumeClaim. To completely remove:

```bash
kubectl delete pvc mysql-pvc
```

## Configuration Files

### Base Deployments

- **backend-deployment.yaml**: Node.js server with PM2, health checks, 2 replicas
- **frontend-deployment.yaml**: React app with nginx, 2 replicas

### Config Maps

- **configmap-local.yaml**: Points backend to `host.docker.internal:3306`
- **configmap-with-mysql.yaml**: Points backend to `mysql-service:3306`

### Optional Components

- **mysql-deployment.yaml**: MySQL 8.0 with persistent storage (10Gi)

## Troubleshooting

### Pods not starting

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Database connection issues

```bash
# Test MySQL connection from backend pod
kubectl exec -it deployment/tombolo-backend -- curl http://localhost:3001/api/status

# Test MySQL from host (K8s MySQL only)
mysql -h 127.0.0.1 -P 30306 -u root -p
```

### Rebuild and redeploy

```bash
# Rebuild images
cd Tombolo/server && docker build -t tombolo-backend:latest .
cd ../client-reactjs && docker build -t tombolo-frontend:latest .

# Delete pods to use new images
kubectl delete pods -l app=tombolo-backend
kubectl delete pods -l app=tombolo-frontend
```

## Environment Variables

All environment variables are managed through:

- `secrets.yaml` - Sensitive data (passwords, keys, tokens)
- `config/configmap-*.yaml` - Non-sensitive configuration

See [`base/secrets.yaml.example`](base/secrets.yaml.example) for required secrets.

## Notes

- Frontend uses nginx to proxy `/api` requests to backend
- Backend connects to MySQL using credentials from secrets
- Health checks ensure pods are ready before receiving traffic
- Persistent volumes retain MySQL data across pod restarts
