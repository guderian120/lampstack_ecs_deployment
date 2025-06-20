

output "monitoring_sg_id" {
  description = "ID of the monitoring server security group"
  value       = aws_security_group.monitoring.id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.lamp_stack_dashboard.dashboard_name}"
}

output "monitoring_instance_profile" {
  description = "Instance profile for the monitoring server"
  value       = aws_iam_instance_profile.monitoring_profile.name  
  
}