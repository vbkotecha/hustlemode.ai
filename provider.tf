# provider.tf
#
# This file configures the AWS provider and sets up the backend configuration
# for storing Terraform state. It includes provider version constraints and
# backend configuration for secure state management.
#
# Author: Infrastructure Team
# Last Updated: 2024

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"

  # Production-ready backend configuration using S3 with state locking
  backend "s3" {
    bucket         = "hustlemode-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "hustlemode-terraform-lock"
  }
}

# AWS Provider Configuration
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  # Production-ready provider settings
  default_tags {
    tags = local.required_tags
  }

  assume_role {
    role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformExecutionRole"
  }
} 