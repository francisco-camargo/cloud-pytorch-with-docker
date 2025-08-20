# provider.tf
# This file configures the AWS provider for deploying EC2 infrastructure.
# Focused on cloud deployment only - no local Docker management needed.

# Terraform configuration block - defines minimum Terraform version and required providers
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    # AWS provider for cloud infrastructure deployment
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider configuration - uses variables for region and profile
provider "aws" {
  region  = var.region
  profile = var.aws_profile
}
