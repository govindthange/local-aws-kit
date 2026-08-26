terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock-key"
  secret_key                  = "mock-secret"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    s3          = "http://floci-emulator:4566"
    kms         = "http://floci-emulator:4566"
    rds         = "http://floci-emulator:4566"
    # rds       = "http://floci-emulator:4566/rds" # 👈 Redirect docdb to rds endpoint
    docdb       = "http://floci-emulator:4566"
    elasticache = "http://floci-emulator:4566"
    ec2         = "http://floci-emulator:4566"
    eks         = "http://floci-emulator:4566"
  }
}