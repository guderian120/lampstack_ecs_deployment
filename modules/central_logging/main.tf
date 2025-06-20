# modules/logging/main.tf

locals {
  log_groups = [
    "LAMPstack/ApacheAccess",
    "LAMPstack/ApacheError",
    "LAMPstack/UserData",
    "LAMPstack/Docker",
    "LAMPstack/MemMetrics"
  ]
}

# S3 Bucket for Centralized Logs
resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name
  acl    = "private"

  lifecycle_rule {
    id      = "log-retention"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = var.log_retention_days
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(var.tags, {
    Name = "Centralized Logs Bucket"
  })
}

# S3 Bucket Policy for ALB and CloudWatch Logs
resource "aws_s3_bucket_policy" "logs_policy" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.alb_account_id}:root"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.logs_bucket.arn}/alb-logs/*"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ],
        Resource = [
          "${aws_s3_bucket.logs_bucket.arn}/cloudwatch-logs/*",
          "${aws_s3_bucket.logs_bucket.arn}"
        ],
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lamp_stack" {
  for_each = toset(local.log_groups)

  name              = each.value
  retention_in_days = var.cloudwatch_log_retention
  tags              = var.tags
}

# IAM Policy for EC2 Instances
resource "aws_iam_policy" "instance_logging_policy" {
  name        = "${var.prefix}-instance-logging-policy"
  description = "Permissions for EC2 instances to upload logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          for log_group in local.log_groups :
          "arn:aws:logs:*:*:log-group:${log_group}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.logs_bucket.arn,
          "${aws_s3_bucket.logs_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "instance_logging_attachment" {
  role       = var.ec2_instance_role_name
  policy_arn = aws_iam_policy.instance_logging_policy.arn
}

# Lambda Function for Log Processing
data "archive_file" "lambda_zip" {
  count       = var.enable_s3_export ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/logs-processor.zip"
}

resource "aws_lambda_function" "logs_processor" {
  count         = var.enable_s3_export ? 1 : 0
  function_name = "${var.prefix}-logs-processor"
  role          = aws_iam_role.lambda_logs_role[0].arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  memory_size   = 128
  timeout       = 30

  filename         = data.archive_file.lambda_zip[0].output_path
  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.logs_bucket.id
    }
  }

  tags = var.tags
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_logs_role" {
  count = var.enable_s3_export ? 1 : 0
  name  = "${var.prefix}-lambda-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count      = var.enable_s3_export ? 1 : 0
  role       = aws_iam_role.lambda_logs_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 Access Policy for Lambda
resource "aws_iam_policy" "lambda_s3_access" {
  count = var.enable_s3_export ? 1 : 0
  name  = "${var.prefix}-lambda-s3-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.logs_bucket.arn,
          "${aws_s3_bucket.logs_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  count      = var.enable_s3_export ? 1 : 0
  role       = aws_iam_role.lambda_logs_role[0].name
  policy_arn = aws_iam_policy.lambda_s3_access[0].arn
}

# CloudWatch Logs Subscription
resource "aws_cloudwatch_log_subscription_filter" "s3_export" {
  count           = var.enable_s3_export ? length(local.log_groups) : 0
  name            = "S3Export-${element(local.log_groups, count.index)}"
  log_group_name  = element(local.log_groups, count.index)
  filter_pattern  = ""
  destination_arn = aws_lambda_function.logs_processor[0].arn

  depends_on = [aws_lambda_permission.allow_cloudwatch]
}

# Lambda Invocation Permission
resource "aws_lambda_permission" "allow_cloudwatch" {
  count         = var.enable_s3_export ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.logs_processor[0].function_name
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.lamp_stack["LAMPStack/ApacheAccess"].arn
}

