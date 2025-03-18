# dynamodb.tf
#
# This file configures a DynamoDB table for Hustlemode.ai
# It's used to store message states for the iMessage relay
# Using on-demand pricing for minimal MVP costs
#
# Author: Vivek Kotecha
# Last Updated: 2024

resource "aws_dynamodb_table" "message_state" {
  name           = "hustlemode-message-state-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand pricing
  hash_key       = "chat_id"
  
  attribute {
    name = "chat_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = local.common_tags
}

# Output the table name
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.message_state.name
} 