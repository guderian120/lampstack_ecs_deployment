output "db_instance_endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "The connection endpoint for the RDS instance"
}

output "db_instance_arn" {
  value       = aws_db_instance.this.arn
  description = "The ARN of the RDS instance"
}

output "db_instance_name" {
  value       = var.db_name
  description = "The name of the database"
}

output "db_instance_username" {
  value       = var.username
  description = "The master username for the database"
  sensitive   = true
}

# Modified subnet group output to handle count
output "db_subnet_group_name" {
  value       = var.is_replica ? null : aws_db_subnet_group.this[0].name
  description = "The name of the DB subnet group (null for replicas)"
}