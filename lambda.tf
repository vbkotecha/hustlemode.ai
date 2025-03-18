resource "aws_security_group" "lambda" {
  name        = "discipline-app-lambda-${var.environment}"
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
  name = "discipline-app-lambda-${var.environment}"

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
  name = "discipline-app-lambda-policy-${var.environment}"
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
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "app" {
  filename         = "lambda/function.zip"  # You'll need to create this
  function_name    = "discipline-app-${var.environment}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"

  environment {
    variables = {
      DB_HOST     = aws_db_instance.postgresql.endpoint
      DB_NAME     = aws_db_instance.postgresql.db_name
      DB_USER     = aws_db_instance.postgresql.username
      ENVIRONMENT = var.environment
    }
  }

  vpc_config {
    subnet_ids         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = local.common_tags
} 