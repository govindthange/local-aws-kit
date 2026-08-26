#!/bin/bash
echo "🧪 Running Isolated AWS CLI Verification Tests via Docker..."

run_aws() {
  docker run --rm --network local-aws-net \
    -e AWS_ACCESS_KEY_ID=mock-key -e AWS_SECRET_ACCESS_KEY=mock-secret -e AWS_DEFAULT_REGION=us-east-1 \
    amazon/aws-cli --endpoint-url=http://floci-emulator:4566 "$@"
}

echo "👉 [1/6] AWS DocumentDB: Provisioning Cluster via AWS API..."
run_aws docdb create-db-cluster \
  --db-cluster-identifier local-mongo-cluster \
  --engine docdb \
  --master-username admin \
  --master-user-password password123 >/dev/null 2>&1 || true

echo "👉 [1/6] AWS DocumentDB: Provisioning DB Instance via AWS API..."
run_aws docdb create-db-instance \
  --db-instance-identifier local-mongo-instance \
  --db-cluster-identifier local-mongo-cluster \
  --db-instance-class db.r5.large \
  --engine docdb >/dev/null 2>&1 || true

echo "👉 [1/6] AWS DocumentDB Verification (Describing Clusters):"
run_aws docdb describe-db-clusters --db-cluster-identifier local-mongo-cluster | grep -E "DBClusterIdentifier|Status"

echo -e "\n👉 [2/6] Amazon ElastiCache:"
run_aws elasticache describe-replication-groups --replication-group-id local-cache | grep -E "ReplicationGroupId|Status"

echo -e "\n👉 [3/6] Amazon S3 Storage:"
run_aws s3 ls

echo -e "\n👉 [4/6] AWS KMS Keys:"
run_aws kms list-keys

echo -e "\n👉 [5/6] Amazon EKS (Kubernetes Control Mapping):"
run_aws eks describe-cluster --name micro-eks | grep -E "name|status"

echo -e "\n👉 [6/6] Amazon EC2 Instance Mappings:"
run_aws ec2 describe-instances --filters "Name=tag:Name,Values=LocalComputeNode" | grep -A 2 "Tags"