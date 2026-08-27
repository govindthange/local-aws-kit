# AWS Cluster Verification

Run `./test-cluster.sh` to verify the cluster setup.

```bash
./tests/test-cluster.sh

```

# AWS RDS Service Verification

Run `./test-rds.sh` at any time to instantly test AWS RDS on your local machine.

```bash
./tests/test-rds.sh
```

Note: You won't be able to view the MySQL tables directly inside **floci-ui** (the local AWS web console).

### Q. How to verify database tables?

The actual tables and data live inside your `local-mysql-engine` database container, which requires a MySQL client to inspect.

> **AWS Console Scope:** `floci-ui` acts strictly as an AWS Cloud Control Plane emulator UI. Standard AWS RDS Web Consoles only show database infrastructure metadata (such as instance status, cluster identifiers, CPU utilization, dynamic ports, and VPC settings). AWS RDS does not expose internal database tables, rows, or schemas directly inside the core AWS RDS dashboard UI.

### Verify Tables & Data w/ Graphical Web Explorer (Adminer)

Navigate to **`http://localhost:8082`** in your web browser and log in:

* **System:** `MySQL`
* **Server:** `local-mysql-engine`
* **Username:** `root` (or `admin`)
* **Password:** `password123`
* **Database:** `test_db`

### Verify Tables & Data w/ Desktop GUI Tools

Connect your favorite desktop database client (such as DBeaver, MySQL Workbench, TablePlus, or DataGrip) directly to your local machine:

* **Host:** `localhost`
* **Port:** `3306`
* **Username:** `root` (or `admin`)
* **Password:** `password123`
* **Database:** `test_db`

### Verify Tables & Data w/ CLI

Inspect the tables and contents via terminal at any time using `docker exec`:

```bash
docker exec -it local-mysql-engine mysql -u root -ppassword123 -e "USE test_db; SHOW TABLES; SELECT * FROM users;"

```

# Isolated AWS API Tests via Docker

Run `./test-services.sh` at any time to instantly test various AWS services with zero clutter on your local machine.

```bash
./tests/test-services.sh
./tests/test-docdb.sh
```

# AWS Serverless Function Verification

Run `./test-lambda.sh` at any time to instantly test AWS Lambda on your local machine.

```bash
./tests/test-lambda.sh
```

This script build 2 functions like so:
1. A pure arithmetic Lambda function. The **Addition Lambda** accepts `num1` and `num2` inside the `--payload` parameter and returns the evaluated sum.
2. A Python (or Node.js) Lambda function that accepts DocumentDB/MongoDB connection parameters via event arguments (or environment variables) and fetches data from your local DocumentDB database setup. The **DocDB Fetcher Lambda** takes `host`, `port`, `username`, `password`, `database`, and `collection` parameters passed as JSON inside the invocation payload.

Both executes inside the shared `local-aws-net` Docker network so the Lambda container can seamlessly talk to `local-mongo-cluster:27017`.


# AWS CLI Verification inside Host

To verify each of the 6 simulated services, run these test commands from your host machine terminal.

#### 🔧 Prep your host environment parameters:

```bash
export AWS_ACCESS_KEY_ID=mock-key
export AWS_SECRET_ACCESS_KEY=mock-secret
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566
```

#### Test 1: Amazon MongoDB (DocumentDB)
Verify that the cluster control plane exists and matches the architecture defined in Terraform:

```bash
aws docdb describe-db-clusters --db-cluster-identifier local-mongo-cluster
```

#### Test 2: Amazon ElastiCache
Confirm that Floci has successfully provisioned a real underlying Redis engine tracking layer:

```bash
aws elasticache describe-cache-clusters --cache-cluster-id local-cache
```

#### Test 3: Amazon S3
Create a temporary dummy file and upload it directly into your local S3 object container:

```bash
echo "Testing local object store" > sample.txt
aws s3 cp sample.txt s3://application-assets/
aws s3 ls s3://application-assets/
```

#### Test 4: KMS Keys
List the encryption elements to confirm your cryptographic control plane keys are active:

```bash
aws kms list-keys
```

#### Test 5: Amazon EKS
Query the cluster metadata parameters to confirm EKS control plane mapping validation:

```bash
aws eks describe-cluster --name micro-eks
```

#### Test 6: Amazon EC2
Inspect your EC2 instances to verify that the proxy virtual machine container is online and tagged properly:

```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=LocalComputeNode"
```
