#!/bin/bash
set -e

echo "🚀 Commencing unified environment orchestration..."

echo "🔹 [1/4] Booting Core Platform Cloud Engine (Stack 1)..."
cd backend-infra && docker compose up -d && cd ..

echo "🔹 [2/4] Constructing High-Fidelity KinD Cluster Matrix..."
kind create cluster --name local-eks --config local-kubernetes/kind-config.yaml

echo "🔹 [3/4] Blending Virtual Kubernetes Nodes into the Host AWS Virtual Switch..."
docker network connect local-aws-net local-eks-control-plane
docker network connect local-aws-net local-eks-worker
docker network connect local-aws-net local-eks-worker2

echo "🔹 [4/4] Deploying NGINX Ingress Routing Platform inside KinD..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/cloud/deploy.yaml

echo "⏳ Waiting for Ingress controller readiness parameters..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "✨ Base Environment is operational! Run Stack 2 to apply your infrastructure blueprints."