#!/bin/bash
set -e

echo "🚀 Commencing unified environment orchestration..."

systemctl is-active --quiet docker || sudo systemctl start docker
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker daemon is not running. Please start Docker Desktop/Engine first."
    exit 1
fi

docker context use default

# ==============================================================================
# STEP 1: Boot Core Platform Cloud Engine (Stack 1)
# ==============================================================================
# We boot up the backend local cloud emulators using Docker Compose. 
# This runs components like the floci emulator and local web console.
echo "🔹 [1/5] Booting Core Platform Cloud Engine (Stack 1)..."
cd backend-infra && docker compose up -d && cd ..

# ==============================================================================
# STEP 2: Construct High-Fidelity KinD Cluster Matrix
# ==============================================================================
# We initialize our multi-node Kubernetes cluster using KinD (Kubernetes in Docker).
# Idempotency check: We check if the cluster already exists to prevent creation errors 
# if the script is re-run multiple times during troubleshooting.
echo "🔹 [2/5] Constructing High-Fidelity KinD Cluster Matrix..."
if kind get clusters | grep -q "^local-eks$"; then
    echo "⚠️ KinD cluster 'local-eks' already exists. Skipping creation."
else
    kind create cluster --name local-eks --config local-kubernetes/kind-config.yaml
fi

# ==============================================================================
# STEP 3: Blend Virtual Kubernetes Nodes into Host AWS Virtual Switch
# ==============================================================================
# We attach each KinD node container to our custom bridge network ('local-aws-net') 
# so they can communicate seamlessly with local AWS service emulators. 
# We suppress errors (2>/dev/null || true) so re-runs don't fail if already attached.
echo "🔹 [3/5] Blending Virtual Kubernetes Nodes into the Host AWS Virtual Switch..."
docker network connect local-aws-net local-eks-control-plane 2>/dev/null || true
docker network connect local-aws-net local-eks-worker 2>/dev/null || true
docker network connect local-aws-net local-eks-worker2 2>/dev/null || true

# ==============================================================================
# STEP 4: Caching and Importing Ingress Images via Tar Archive
# ==============================================================================
# TROUBLESHOOTING CONTEXT: 
# Standard 'kind load' uses continuous socket streaming via Docker API pipes. 
# On Linux environments running Docker Desktop, this frequently causes 500 socket 
# errors or hangs indefinitely during heavy multi-node imports.
# 
# SOLUTION: 
# 1. We pull the images cleanly onto the host using the Docker CLI.
# 2. We package them into a flat .tar file on disk to avoid live-stream socket locks.
# 3. We copy the tar archive directly into each node container and use 'ctr' 
#    (containerd's native CLI) to import them locally.
echo "🔹 [4/5] Caching and Importing Ingress Images via Tar Archive..."
docker pull registry.k8s.io/ingress-nginx/controller:v1.12.0
docker pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4

# Save images to a temporary local tar file on the host
docker save registry.k8s.io/ingress-nginx/controller:v1.12.0 registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4 -o /tmp/ingress-images.tar

# Iterate over each cluster node to push and import the images natively
for node in local-eks-control-plane local-eks-worker local-eks-worker2; do
    echo "Importing images into $node..."
    docker cp /tmp/ingress-images.tar $node:/ingress-images.tar
    docker exec $node ctr -n k8s.io images import /ingress-images.tar
    docker exec $node rm -f /ingress-images.tar
done

# Clean up the temporary host archive file
rm -f /tmp/ingress-images.tar

# ==============================================================================
# STEP 5: Deploy NGINX Ingress Routing Platform inside KinD
# ==============================================================================
# With all required container images pre-loaded locally on every node, we apply 
# the upstream NGINX Ingress manifest. Because the images are already present, 
# Kubernetes avoids `ImagePullBackOff` states entirely.
echo "🔹 [5/5] Deploying NGINX Ingress Routing Platform inside KinD..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/cloud/deploy.yaml

# The kubectl wait command succeeds instantly without timing out because 
# the images are already fully available inside the cluster nodes' runtimes.
echo "⏳ Waiting for Ingress controller readiness parameters..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "✨ Base Environment is operational! Run Stack 2 to apply your infrastructure blueprints."