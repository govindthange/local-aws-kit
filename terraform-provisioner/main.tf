resource "aws_docdb_cluster" "local_mongo" {
  cluster_identifier  = "local-mongo-cluster"
  engine              = "docdb"
  master_username     = "admin"
  master_password     = "password123"
  skip_final_snapshot = true
}

resource "aws_elasticache_cluster" "local_cache" {
  cluster_id           = "local-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
}

resource "aws_s3_bucket" "local_storage" {
  bucket        = "application-assets"
  force_destroy = true
}

resource "aws_kms_key" "local_key" {
  description             = "Default Local Application Key"
  deletion_window_in_days = 7
}

resource "aws_eks_cluster" "local_eks" {
  name     = "micro-eks"
  role_arn = "arn:aws:iam::000000000000:role/mock-eks-role"
  vpc_config {
    subnet_ids = ["subnet-00000000", "subnet-11111111"]
  }
}

resource "aws_instance" "local_compute" {
  ami           = "ami-mock"
  instance_type = "t3.micro"
  tags = { Name = "LocalComputeNode" }
}
