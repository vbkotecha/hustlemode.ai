# dns.tf
#
# This file configures DNS records for Hustlemode.ai services
# using Route 53 for both Redis and RDS endpoints.
#
# Author: Vivek Kotecha
# Last Updated: 2024

# Get the hosted zone for your domain
data "aws_route53_zone" "main" {
  name = "hustlemode.ai"  # Replace with your actual domain
}

# DNS record for Redis
resource "aws_route53_record" "redis" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "redis.${var.environment}.hustlemode.ai"  # e.g., redis.dev.hustlemode.ai
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticache_cluster.redis.cache_nodes[0].address]
}

# DNS record for RDS
resource "aws_route53_record" "rds" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "db.${var.environment}.hustlemode.ai"  # e.g., db.dev.hustlemode.ai
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.postgresql.endpoint]
}

# Outputs
output "redis_dns" {
  description = "DNS name for Redis endpoint"
  value       = aws_route53_record.redis.fqdn
}

output "rds_dns" {
  description = "DNS name for RDS endpoint"
  value       = aws_route53_record.rds.fqdn
} 