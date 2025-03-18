terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"  # Default region, can be overridden by variables
}

# Variables
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "db_password" {
  description = "Password for RDS instance"
  type        = string
  sensitive   = true
}

# Tags that will be applied to all resources
locals {
  common_tags = {
    Environment = var.environment
    Project     = "discipline-accountability-app"
    ManagedBy   = "terraform"
  }
} 