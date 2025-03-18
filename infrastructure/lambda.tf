resource "aws_security_group" "lambda" {
  name        = "hustlemode-lambda-${var.environment}"
  description = "Security group for Lambda functions"
  vpc_id      = aws_default_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_iam_role" "lambda" {
  name = "hustlemode-lambda-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "lambda" {
  name = "hustlemode-lambda-policy-${var.environment}"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "sns:Publish",
          "sns:CreatePlatformEndpoint",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "app" {
  filename         = "lambda/function.zip"  # You'll need to create this
  function_name    = "hustlemode-app-${var.environment}"
  role            = aws_iam_role.lambda.arn
  handler         = "handler.handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      ENVIRONMENT     = var.environment
      REDIS_ENDPOINT  = aws_elasticache_cluster.redis.cache_nodes[0].address
      REDIS_PORT      = aws_elasticache_cluster.redis.cache_nodes[0].port
      SNS_TOPIC_ARN   = aws_sns_topic.user_notifications.arn
    }
  }

  vpc_config {
    subnet_ids         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = local.common_tags
} 