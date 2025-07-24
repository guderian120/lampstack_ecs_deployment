# modules/dr_region/lambda.tf
resource "aws_lambda_function" "failover_lambda" {
  filename      = "${path.module}/failover_function/ecs_failover_lambda.zip"
  function_name = "dr-failover-trigger"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 300
  environment {
    variables = {
      DR_ECS_CLUSTER      = "dr_ecsstack-cluster"
      DR_ECS_SERVICE      = "dr_ecsstack-service"
      DR_RDS_ID = "dr-ecs-db"
      DR_ALB_LISTENER_ARN = var.DR_ALB_LISTENER_ARN 
    }
  }
}

# IAM Role (ECS + ALB + RDS permissions)
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-failover-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ecs_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_alb_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

# SNS Invoke Permission
resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn # From primary region
}



# modules/dr_region/sns_subscription.tf
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = var.sns_topic_arn # Primary region SNS
  protocol  = "lambda"
  endpoint  = aws_lambda_function.failover_lambda.arn
}