output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.this[*].id
}

# output "instance_public_ips" {
#   description = "List of public IP addresses of EC2 instances"
#   value       = aws_eip.this[*].public_ip
# }

# output "instance_private_ips" {
#   description = "List of private IP addresses of EC2 instances"
#   value       = aws_instance.this[*].private_ip
# }