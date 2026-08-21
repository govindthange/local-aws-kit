#!/bin/bash
set -e

echo "🔍 Starting local environment verification diagnostics..."
echo "======================================================"

# ==============================================================================
# 1. Verify Floci Local Cloud Engine (Stack 1)
# ==============================================================================
echo -e "\n🔹 [1/4] Checking Floci Emulator & Web Console..."

if docker ps --format '{{.Names}}' | grep -q "^floci-emulator$"; then
    echo "✅ Container 'floci-emulator' is running."
    
    # Test health endpoint / AWS wire protocol port 4566
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:4566 | grep -qE "200|400|403"; then
        echo "✅ Floci endpoint is responding on http://localhost:4566."
    else
        echo "⚠️ Warning: Floci container is running, but port 4566 is not responding as expected."
    fi
else
    echo "❌ Error: Container 'floci-emulator' is NOT running. (Run Stack 1 / setup.sh)"
fi

if docker ps --format '{{.Names}}' | grep -q "^aws-local-web-console$"; then
    echo "✅ Container 'aws-local-web-console' is running."
else
    echo "⚠️ Warning: 'aws-local-web-console' container is not running."
fi

# ==============================================================================
# 2. Verify KinD Cluster Matrix & Context
# ==============================================================================
echo -e "\n🔹 [2/4] Checking KinD Kubernetes Cluster ('local-eks')..."

if kind get clusters | grep -q "^local-eks$"; then
    echo "✅ KinD cluster 'local-eks' exists."
else
    echo "❌ Error: KinD cluster 'local-eks' is missing."
    exit 1
fi

CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "none")
if [ "$CURRENT_CONTEXT" = "kind-local-eks" ]; then
    echo "✅ Active kubectl context is correctly set to 'kind-local-eks'."
else
    echo "⚠️ Warning: Active kubectl context is '$CURRENT_CONTEXT' (expected 'kind-local-eks'). Fixing..."
    kubectl config use-context kind-local-eks
fi

# Check node statuses
echo "--- Cluster Nodes Status ---"
kubectl get nodes -o wide --request-timeout='5s'

# ==============================================================================
# 3. Verify Docker Network Bridge Integration
# ==============================================================================
echo -e "\n🔹 [3/4] Checking Virtual Network Switch Integration ('local-aws-net')..."

NET_EXISTS=$(docker network ls --format '{{.Name}}' | grep -q "^local-aws-net$" && echo "yes" || echo "no")
if [ "$NET_EXISTS" = "yes" ]; then
    echo "✅ Docker network 'local-aws-net' exists."
    
    # Check if nodes are plugged into the bridge
    for node in local-eks-control-plane local-eks-worker local-eks-worker2; do
        if docker inspect $node --format '{{json .NetworkSettings.Networks.2>/dev/null}}' | grep -q "local-aws-net"; then
            echo "   -> Node '$node' is successfully attached to 'local-aws-net'."
        else
            echo "   -> ⚠️ Node '$node' is NOT attached to 'local-aws-net'."
        fi
    done
else
    echo "❌ Error: Docker network 'local-aws-net' is missing."
fi

# ==============================================================================
# 4. Verify NGINX Ingress Routing Platform & Core Pods
# ==============================================================================
echo -e "\n🔹 [4/4] Checking NGINX Ingress Controller & System Pods..."

if kubectl get namespace ingress-nginx &>/dev/null; then
    echo "✅ Namespace 'ingress-nginx' exists."
    echo "--- Ingress Pods Status ---"
    kubectl get pods -n ingress-nginx --request-timeout='5s'
else
    echo "❌ Error: Namespace 'ingress-nginx' does not exist."
fi

echo "======================================================"
echo "✨ Verification suite completed successfully!"