resource "aws_apigatewayv2_api" "main" {
  name          = "discipline-app-${var.environment}"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["*"]
  }

  tags = local.common_tags
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true

  tags = local.common_tags
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.app.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "main" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /checkin"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# CloudWatch Events (EventBridge) rule for daily check-ins
resource "aws_cloudwatch_event_rule" "daily_checkin" {
  name                = "discipline-app-daily-checkin-${var.environment}"
  description         = "Triggers daily check-in Lambda function"
  schedule_expression = "cron(0 12 * * ? *)"  # Runs at 12:00 PM UTC daily

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "daily_checkin" {
  rule      = aws_cloudwatch_event_rule.daily_checkin.name
  target_id = "DailyCheckinLambda"
  arn       = aws_lambda_function.app.arn
}

resource "aws_lambda_permission" "cloudwatch_events" {
  statement_id  = "AllowCloudWatchEventsInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_checkin.arn
}

# Outputs
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgresql.endpoint
} 