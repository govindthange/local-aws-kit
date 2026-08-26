#!/bin/bash
set -e

echo "🛑 Initiating graceful system shutdown..."

# ==============================================================================
# STEP 1: Terminate Runner Container & Purge Terraform Caches
# ==============================================================================
echo "🔹 [1/3] Terminating active Terraform runner containers..."
if docker ps -a --format '{{.Names}}' | grep -q "^local-terraform-runner$"; then
    docker stop local-terraform-runner >/dev/null 2>&1 || true
    docker rm local-terraform-runner >/dev/null 2>&1 || true
    echo "   ✔ Removed container: local-terraform-runner"
else
    echo "   ℹ No active local-terraform-runner container found."
fi

# Clean up local Terraform lock files and cache directories to prevent state conflicts
if [ -d "terraform-provisioner" ]; then
    echo "   🧹 Cleaning up local Terraform caches..."
    rm -f terraform-provisioner/.terraform.lock.hcl
    rm -rf terraform-provisioner/.terraform
    echo "   ✔ Cleared .terraform cache and dependency lock file."
fi

# ==============================================================================
# STEP 2: Pause KinD Kubernetes Cluster Containers
# ==============================================================================
echo "🔹 [2/3] Pausing KinD Cluster Nodes..."
NODES=$(docker ps -a --filter "name=local-eks-" --format "{{.Names}}")

if [ -n "$NODES" ]; then
    for node in $NODES; do
        if [ "$(docker inspect -f '{{.State.Running}}' "$node" 2>/dev/null)" = "true" ]; then
            echo "   ⏸ Stopping container: $node..."
            docker stop "$node" > /dev/null
        else
            echo "   ℹ Container $node is already stopped."
        fi
    done
else
    echo "   ℹ No 'local-eks' nodes found to pause."
fi

# ==============================================================================
# STEP 3: Stop Core Platform Backend Services (Stack 1)
# ==============================================================================
echo "🔹 [3/3] Stopping Core Platform Cloud Engine (Stack 1)..."
if [ -d "backend-infra" ]; then
    cd backend-infra && docker compose stop && cd ..
    echo "   ✔ Core backend infrastructure paused."
else
    echo "   ⚠️ 'backend-infra' directory not found; skipping Stack 1 shutdown."
fi

echo "✨ All components successfully stopped and cleared! Run './restart.sh' to resume."