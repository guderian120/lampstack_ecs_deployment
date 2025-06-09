output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "web_security_group_id" {
  description = "The ID of the web server security group"
  value       = aws_security_group.web.id
}

output "database_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.database.id
}