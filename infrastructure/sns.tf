# sns.tf
#
# This file configures Amazon SNS for sending RCS messages to iPhones
# via the Apple Push Notification service (APNs).
#
# Author: Vivek Kotecha
# Last Updated: 2024

# SNS Topic for user notifications
resource "aws_sns_topic" "user_notifications" {
  name = "hustlemode-notifications-${var.environment}"
  
  tags = local.common_tags
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.user_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaPublish"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.user_notifications.arn
      }
    ]
  })
}

# Add SNS publishing permissions to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sns" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda-sns-publish-${var.environment}"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:CreatePlatformEndpoint"
        ]
        Resource = [
          aws_sns_topic.user_notifications.arn
        ]
      }
    ]
  })
}

# Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic for user notifications"
  value       = aws_sns_topic.user_notifications.arn
} 