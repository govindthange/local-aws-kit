#!/bin/bash
echo "🧪 Running Isolated AWS DOCDB Verification Tests via Docker..."

run_aws() {
  docker run --rm --network local-aws-net \
    -e AWS_ACCESS_KEY_ID=mock-key -e AWS_SECRET_ACCESS_KEY=mock-secret -e AWS_DEFAULT_REGION=us-east-1 \
    amazon/aws-cli --endpoint-url=http://floci-emulator:4566 "$@"
}

echo "👉 [1/4] AWS DocumentDB: Provisioning Cluster via AWS API..."
run_aws docdb create-db-cluster \
  --db-cluster-identifier local-mongo-cluster \
  --engine docdb \
  --master-username admin \
  --master-user-password password123 >/dev/null 2>&1 || true

echo "👉 [2/4] AWS DocumentDB: Provisioning DB Instance via AWS API..."
run_aws docdb create-db-instance \
  --db-instance-identifier local-mongo-instance \
  --db-cluster-identifier local-mongo-cluster \
  --db-instance-class db.r5.large \
  --engine docdb >/dev/null 2>&1 || true

echo "👉 [3/4] AWS DocumentDB Verification (Describing Clusters):"
run_aws docdb describe-db-clusters --db-cluster-identifier local-mongo-cluster | grep -E "DBClusterIdentifier|Status"

echo -e "\n👉 [4/4] DocumentDB Data Operations: Creating Collections, Documents, and Indexes..."

# Execute mongosh commands against the local-mongo-cluster container
docker run --rm --network local-aws-net mongo:6.0 mongosh \
  "mongodb://admin:password123@local-mongo-cluster:27017/admin" --eval '
    // 1. Switch / Create Database
    const db = db.getSiblingDB("test_docdb");

    // 2. Create Collection explicitly
    db.createCollection("users");

    // 3. Create Index on "email" field
    db.users.createIndex({ email: 1 }, { unique: true });

    // 4. Insert Sample Documents
    db.users.insertMany([
      { username: "govind", email: "gthange@yahoo.com", role: "admin", createdAt: new Date() },
      { username: "thange", email: "gthange@outlook.com", role: "user", createdAt: new Date() }
    ]);

    // 5. Query Documents & Fields
    console.log("\n--- INSERTED DOCUMENTS ---");
    console.log(db.users.find().toArray());

    // 6. Verify Created Indexes
    console.log("\n--- COLLECTION INDEXES ---");
    console.log(db.users.getIndexes());
'