#!/bin/bash
set -e

echo "🚀 Commencing unified environment orchestration..."

echo "🔹 [1/5] Booting Core Platform Cloud Engine (Stack 1)..."
cd backend-infra && docker compose up -d && cd ..

echo "🔹 [2/5] Constructing High-Fidelity KinD Cluster Matrix..."
if kind get clusters | grep -q "^local-eks$"; then
    echo "⚠️ KinD cluster 'local-eks' already exists. Skipping creation."
else
    kind create cluster --name local-eks --config local-kubernetes/kind-config.yaml
fi

echo "🔹 [3/5] Blending Virtual Kubernetes Nodes into the Host AWS Virtual Switch..."
docker network connect local-aws-net local-eks-control-plane 2>/dev/null || true
docker network connect local-aws-net local-eks-worker 2>/dev/null || true
docker network connect local-aws-net local-eks-worker2 2>/dev/null || true

echo "🔹 [4/5] Caching and Importing Ingress Images via Tar Archive..."
docker pull registry.k8s.io/ingress-nginx/controller:v1.12.0
docker pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4

# Write a flat .tar file to disk first, then copies it into the nodes using raw container execution, completely sidestepping the process lockup.
docker save registry.k8s.io/ingress-nginx/controller:v1.12.0 registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4 -o /tmp/ingress-images.tar

for node in local-eks-control-plane local-eks-worker local-eks-worker2; do
    echo "Importing images into $node..."
    docker cp /tmp/ingress-images.tar $node:/ingress-images.tar
    docker exec $node ctr -n k8s.io images import /ingress-images.tar
    docker exec $node rm -f /ingress-images.tar
done

rm -f /tmp/ingress-images.tar

echo "🔹 [5/5] Deploying NGINX Ingress Routing Platform inside KinD..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/cloud/deploy.yaml

# The kubectl wait command will now succeed instantly because the images will already be fully present inside the cluster nodes before the manifest is applied.
echo "⏳ Waiting for Ingress controller readiness parameters..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "✨ Base Environment is operational! Run Stack 2 to apply your infrastructure blueprints."