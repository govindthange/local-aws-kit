#!/bin/bash
set -e

echo "🔄 Restarting local cloud and Kubernetes environment..."

# ==============================================================================
# STEP 1: Verify Docker Engine Readiness
# ==============================================================================
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker daemon is not running. Please start Docker Desktop/Engine first."
    exit 1
fi

# ==============================================================================
# STEP 2: Resume Core Platform Backend Engine (Stack 1)
# ==============================================================================
echo "🔹 [1/4] Resuming Core Platform Cloud Engine (Stack 1)..."
cd backend-infra && docker compose up -d && cd ..

# Discover existing KinD cluster nodes
NODES=$(docker ps -a --filter "name=local-eks-" --format "{{.Names}}")

if [ -z "$NODES" ]; then
    echo "⚠️ No existing 'local-eks' nodes found. Run './setup.sh' to perform initial provisioning."
    exit 1
fi

# ==============================================================================
# STEP 3: Resume Stopped KinD Kubernetes Cluster Nodes
# ==============================================================================
echo "🔹 [2/4] Restarting KinD Cluster Containers..."
echo "📋 Targeted KinD nodes to start:"
for node in $NODES; do
    echo "   - $node"
done

for node in $NODES; do
    echo "   🚀 Starting container: $node..."
    docker start "$node" > /dev/null
done

# Ensure active context is configured to local-eks
kubectl config use-context kind-local-eks > /dev/null 2>&1 || true

# ==============================================================================
# STEP 4: Re-attach Virtual Network Switch Bridges
# ==============================================================================
echo "🔹 [3/4] Re-attaching KinD Nodes to 'local-aws-net' Switch..."
echo "📋 Targeted KinD nodes for network attachment:"
for node in $NODES; do
    echo "   - $node"
done

for node in $NODES; do
    echo "   🔌 Connecting $node to local-aws-net..."
    docker network connect local-aws-net "$node" 2>/dev/null || true
done

# ==============================================================================
# STEP 5: Re-trigger Infrastructure Provisioning (Stack 2)
# ==============================================================================
echo "🔹 [4/4] Applying Declarative Terraform Resources (Stack 2)..."
cd terraform-provisioner && docker compose up && cd ..

echo "✨ System environment successfully resumed!"
echo "👉 Run './verify-cluster.sh' to confirm all components are healthy."
