#!/bin/bash
echo "🧪 Running Isolated AWS CLI Verification Tests via Docker..."

run_aws() {
  docker run --rm --network local-aws-net \
    -e AWS_ACCESS_KEY_ID=mock-key -e AWS_SECRET_ACCESS_KEY=mock-secret -e AWS_DEFAULT_REGION=us-east-1 \
    amazon/aws-cli --endpoint-url=http://floci-emulator:4566 "$@"
}

echo "👉 [1/3] AWS RDS Aurora MySQL: Provisioning Cluster via AWS API..."
run_aws rds create-db-cluster \
  --db-cluster-identifier local-rds-cluster \
  --engine aurora-mysql \
  --master-username admin \
  --master-user-password password123 >/dev/null 2>&1 || true

echo "👉 [2/3] AWS RDS Verification (Describing Clusters):"
run_aws rds describe-db-clusters --db-cluster-identifier local-rds-cluster | grep -E "DBClusterIdentifier|Status|Engine"

echo "👉 [3/3] Database Execution: Creating Schema, Table, and Querying Data..."
# Execute SQL commands against the local-mysql-engine container on local-aws-net network
docker run --rm --network local-aws-net \
  -e MYSQL_PWD=password123 \
  mysql:8.0 mysql -h local-mysql-engine -u root -e "
    -- 1. Create Schema / Database
    CREATE DATABASE IF NOT EXISTS test_db;
    USE test_db;

    -- 2. Create Table
    CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(50) NOT NULL,
      email VARCHAR(100) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- 3. Insert Test Data
    INSERT INTO users (username, email) VALUES 
      ('alice', 'alice@example.com'),
      ('bob', 'bob@example.com');

    -- 4. Query Test
    SELECT '--- QUERY TEST RESULTS ---' AS Status;
    SELECT * FROM users;
"