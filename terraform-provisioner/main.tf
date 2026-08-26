# # Option 1 - failed
# resource "aws_docdb_cluster" "local_mongo" {
#   cluster_identifier  = "local-mongo-cluster"
#   engine              = "docdb"
#   master_username     = "admin"
#   master_password     = "password123"
#   skip_final_snapshot = true
# 
#   lifecycle {
#     ignore_changes = [
#       global_cluster_identifier,
#     ]
#   }
# }

# # Option 2 - failed
# resource "aws_docdb_cluster" "local_mongo" {
#   cluster_identifier  = "local-mongo-cluster"
#   engine              = "docdb"
#   master_username     = "admin"
#   master_password     = "password123"
#   skip_final_snapshot = true
# }

# # Option 3 - failed
# resource "aws_docdb_instance" "local_mongo_instance" {
#   cluster_identifier = "local-mongo-cluster"
#   instance_class     = "db.r5.large"
#   engine             = "docdb"
# }

# Option 4
# Register DocumentDB cluster metadata
resource "null_resource" "register_docdb" {
  provisioner "local-exec" {
    command = <<EOT
      wget --quiet \
        --header="Content-Type: application/x-www-form-urlencoded" \
        --post-data="Action=CreateDBCluster" \
        "&DBClusterIdentifier=local-mongo-cluster" \
        "&Engine=docdb" \
        "&MasterUsername=admin" \
        "&MasterUserPassword=password123" \
        "&Version=2014-10-31" \
        "http://floci-emulator:4566/" \
        -O - || true
    EOT
  }
}

# 'engine' field value could be one of ["aurora-mysql" "aurora-postgresql" "mysql" "postgres"]
resource "aws_rds_cluster" "local_rds_instance" {
  cluster_identifier  = "local-rds-cluster"
  engine              = "aurora-mysql"
  master_username     = "admin"
  master_password     = "password123"
  skip_final_snapshot = true
}

# Standard Redis instance without subnet groups
resource "aws_elasticache_replication_group" "local_cache" {
  replication_group_id = "local-cache"
  description          = "Local Redis cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_clusters   = 1
  port                 = 6379
  parameter_group_name = "default.redis7"
}

resource "aws_s3_bucket" "local_storage" {
  bucket        = "application-assets"
  force_destroy = true
}

resource "aws_kms_key" "local_key" {
  description             = "Default Local Application Key"
  deletion_window_in_days = 7
}

# 1. Define a mock VPC for the EKS cluster
resource "aws_vpc" "local_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "local-vpc"
  }
}

# 2. Define mock Subnets
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.local_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "local-subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.local_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "local-subnet-b"
  }
}

resource "aws_eks_cluster" "local_eks" {
  name     = "micro-eks"
  role_arn = "arn:aws:iam::000000000000:role/mock-eks-role"
  
  vpc_config {
    subnet_ids = [
      aws_subnet.subnet_a.id,
      aws_subnet.subnet_b.id
    ]
  }
}

resource "aws_instance" "local_compute" {
  ami           = "ami-mock"
  instance_type = "t3.micro"
  tags = { Name = "LocalComputeNode" }
}