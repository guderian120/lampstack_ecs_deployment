output "db_instance_id" {
  description = "The ID of the DB instance"
  value       = aws_db_instance.this.id
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_username" {
  description = "The master username"
  value       = aws_db_instance.this.username
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.this.name
}