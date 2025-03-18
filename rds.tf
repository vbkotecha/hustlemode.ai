# rds.tf
#
# This file configures the RDS instance and associated security groups
# for Hustlemode.ai. It uses the default VPC for MVP but restricts access
# to specific IP addresses for the Python API.
#
# Author: Vivek Kotecha
# Last Updated: 2024

resource "aws_db_subnet_group" "main" {
  name       = "hustlemode-${var.environment}"
  subnet_ids = ["${aws_default_subnet.default_az1.id}", "${aws_default_subnet.default_az2.id}"]
  tags       = local.common_tags
}

# Security group for RDS instance
resource "aws_security_group" "rds" {
  name        = "hustlemode-rds-${var.environment}"
  description = "Security group for RDS instance - Allows access from specific IPs"
  vpc_id      = aws_default_vpc.default.id

  # PostgreSQL access from specific IP addresses
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_addresses
    description = "PostgreSQL access from allowed IPs"
  }

  # Explicit deny all other inbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = local.common_tags
}

# RDS Instance
resource "aws_db_instance" "postgresql" {
  identifier           = "hustlemode-${var.environment}"
  engine              = "postgres"
  engine_version      = "14.10"
  instance_class      = "db.t3.micro"  # Smallest instance for MVP
  allocated_storage   = 10             # Minimum storage for MVP
  storage_type        = "gp2"
  
  db_name             = "hustlemode"
  username            = "app_user"
  password            = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 0           # Disable automated backups for MVP
  skip_final_snapshot    = true
  multi_az              = false        # Single AZ deployment for MVP
  publicly_accessible   = true         # Needed for direct IP access
  monitoring_interval   = 0            # Disable enhanced monitoring

  storage_encrypted     = true         # Enable encryption at rest

  tags = local.common_tags
}

# Default VPC and Subnets (for MVP)
resource "aws_default_vpc" "default" {
  tags = merge(local.common_tags, {
    Name = "hustlemode-vpc-${var.environment}"
  })
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${data.aws_region.current.name}a"
  tags = merge(local.common_tags, {
    Name = "hustlemode-subnet-1-${var.environment}"
  })
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "${data.aws_region.current.name}b"
  tags = merge(local.common_tags, {
    Name = "hustlemode-subnet-2-${var.environment}"
  })
}

data "aws_region" "current" {} 