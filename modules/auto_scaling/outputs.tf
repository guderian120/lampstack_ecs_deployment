output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.arn
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.this.id
}

output "ec2_instance_role" {
  description = "The IAM role attached to the EC2 instances in the Auto Scaling Group"
  value       = aws_iam_role.asg_role.name
  
}

output "launch_template_latest_version" {
  description = "The latest version of the Launch Template"
  value       = aws_launch_template.this.latest_version
}

output "asg_capacity" {
  description = "The current capacity of the Auto Scaling Group"
  value = {
    min_size     = aws_autoscaling_group.this.min_size
    max_size     = aws_autoscaling_group.this.max_size
    desired_size = aws_autoscaling_group.this.desired_capacity
  }
}

# Correct way to get instance IDs
data "aws_instances" "asg_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.this.name
  }

  depends_on = [aws_autoscaling_group.this]
}

output "instance_ids" {
  description = "List of EC2 instance IDs in the Auto Scaling Group"
  value       = data.aws_instances.asg_instances.ids
}

output "instance_private_ips" {
  description = "List of private IPs of instances in the Auto Scaling Group"
  value       = data.aws_instances.asg_instances.private_ips
}

output "instance_public_ips" {
  description = "List of public IPs of instances in the Auto Scaling Group"
  value       = data.aws_instances.asg_instances.public_ips
}