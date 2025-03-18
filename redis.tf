# redis.tf
#
# This file configures a Redis instance for Hustlemode.ai
# It's configured for public access (MVP) and optimized for vector operations.
#
# Author: Vivek Kotecha
# Last Updated: 2024

# Security group for Redis - Allow public access
resource "aws_security_group" "redis" {
  name        = "hustlemode-redis-${var.environment}"
  description = "Security group for Redis - Public access for MVP"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from anywhere (for MVP)
    description = "Public Redis access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = local.common_tags
}

# Redis subnet group using public subnets
resource "aws_elasticache_subnet_group" "redis" {
  name       = "hustlemode-redis-${var.environment}"
  subnet_ids = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  
  tags = local.common_tags
}

# Redis parameter group optimized for vector operations
resource "aws_elasticache_parameter_group" "redis" {
  family = "redis7"
  name   = "hustlemode-redis-params-${var.environment}"

  # Parameters optimized for vector operations and AI workloads
  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  parameter {
    name  = "activedefrag"
    value = "yes"
  }

  parameter {
    name  = "maxmemory-samples"
    value = "10"
  }

  tags = local.common_tags
}

# Redis cluster with public access
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "hustlemode-${var.environment}"
  engine              = "redis"
  node_type           = "cache.t3.micro"  # Smallest instance for MVP
  num_cache_nodes     = 1                 # Single node for MVP
  port                = 6379
  
  # Network configuration
  security_group_ids  = [aws_security_group.redis.id]
  subnet_group_name   = aws_elasticache_subnet_group.redis.name

  # Redis configuration
  engine_version      = "7.0"             # Latest stable version with vector support
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  
  # MVP settings
  snapshot_retention_period = 0           # Disable backups for MVP
  maintenance_window       = "sun:05:00-sun:06:00"
  
  # Security settings (minimal for MVP)
  transit_encryption_enabled = false      # Disable encryption for easier access
  auth_token                = null        # No password for MVP

  tags = local.common_tags
}

# Outputs
output "redis_endpoint" {
  description = "The endpoint URL of the Redis instance"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "The port number of the Redis instance"
  value       = aws_elasticache_cluster.redis.port
} 