output "logs_bucket_arn" {
  description = "ARN of the logs bucket"
  value       = aws_s3_bucket.logs_bucket.arn
}

output "logs_bucket_name" {
  description = "Name of the logs bucket"
  value       = aws_s3_bucket.logs_bucket.id
}

output "cloudwatch_log_groups" {
  description = "Map of CloudWatch log group names to their ARNs"
  value       = { for k, v in aws_cloudwatch_log_group.lamp_stack : k => v.arn }
}