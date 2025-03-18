# variables.tf
#
# This file defines all variables used across the infrastructure.
# It includes environment configurations, AWS credentials, database settings,
# and common resource tags. All sensitive values are marked as such and
# should be provided via secure methods (e.g., AWS Secrets Manager, HashiCorp Vault).
#
# Author: Infrastructure Team
# Last Updated: 2024

# Environment Configuration
variable "environment" {
  description = "Deployment environment (dev/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either dev or prod"
  }
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be in format: xx-xxxx-#"
  }
}

variable "aws_access_key" {
  description = "AWS access key for authentication"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("^[A-Z0-9]{20}$", var.aws_access_key))
    error_message = "AWS access key must be 20 characters long and contain only uppercase letters and numbers"
  }
}

variable "aws_secret_key" {
  description = "AWS secret key for authentication"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.aws_secret_key) >= 40
    error_message = "AWS secret key must be at least 40 characters long"
  }
}

# Database Configuration
variable "db_password" {
  description = "Master password for RDS instance"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 16 && can(regex("[A-Z]", var.db_password)) && can(regex("[a-z]", var.db_password)) && can(regex("[0-9]", var.db_password)) && can(regex("[!@#$%^&*()_+]", var.db_password))
    error_message = "Database password must be at least 16 characters and contain uppercase, lowercase, numbers, and special characters"
  }
}

# Resource Sizing
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS instance in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.rds_allocated_storage >= 20 && var.rds_allocated_storage <= 100
    error_message = "RDS storage must be between 20 and 100 GB"
  }
}

# Common resource tags
locals {
  required_tags = {
    Environment     = var.environment
    Project         = "hustlemode-ai"
    ManagedBy      = "terraform"
    Owner          = "infrastructure-team"
    CostCenter     = "tech-${var.environment}"
    SecurityLevel  = var.environment == "prod" ? "high" : "medium"
    BackupRequired = "true"
    LastUpdated    = timestamp()
  }

  # Merge any additional tags with required tags
  common_tags = merge(local.required_tags, {
    DataClassification = var.environment == "prod" ? "confidential" : "internal"
    MaintenanceWindow = var.environment == "prod" ? "sun:03:00-sun:05:00" : "sat:03:00-sat:05:00"
  })
}

# Add this new variable block after the existing variables

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access the RDS instance (in CIDR notation)"
  type        = list(string)
  validation {
    condition     = length(var.allowed_ip_addresses) > 0
    error_message = "At least one IP address must be provided"
  }
  validation {
    condition     = alltrue([for ip in var.allowed_ip_addresses : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", ip))])
    error_message = "IP addresses must be in CIDR notation (e.g., '1.2.3.4/32')"
  }
} 