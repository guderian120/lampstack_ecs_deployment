variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "monitoring_ami" {
  description = "AMI for the monitoring server"
  type        = string
  default     = "ami-03400c3b73b5086e9" # Amazon Linux 2 LTS
}

variable "monitoring_instance_type" {
  description = "Instance type for the monitoring server"
  type        = string
  default     = "t3.micro"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the monitoring server"
  type        = string
}

variable "ssh_ingress_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer (e.g., app/my-alb/1234567890)"
  type        = string
}

variable "db_instance_id" {
  description = "RDS instance identifier"
  type        = string
}

variable "alarm_email" {
  description = "Email for SNS notifications"
  type        = string
}