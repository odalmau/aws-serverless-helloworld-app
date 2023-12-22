terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.1"
    }
  }
  required_version = "~> 1.6.6"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-aws-serverless-helloworld"
    key    = "development"
    region = "us-east-1"
  }
}
