#!/bin/bash
echo "⚠️ Commencing complete environment teardown..."

echo "🛑 Destroying declarative Terraform managed resources (Stack 2)..."
cd terraform-provisioner
docker compose run --rm --entrypoint "/bin/sh -c" terraform "terraform destroy -auto-approve" || true
cd ..

echo "🛑 Deleting the KinD Kubernetes cluster..."
kind delete cluster --name local-eks || true

echo "🛑 Halting Floci Core platform engines and associated volumes (Stack 1)..."
cd backend-infra && docker compose down -v && cd ..

echo "🛑 Cleaning up orphaned runtime container processes from host engine socket..."
docker ps -a --filter "name=floci-" -q | xargs -r docker rm -f || true

echo "✨ Teardown clean complete. Machine is completely reset."
