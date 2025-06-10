variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "lamp-monitoring"
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "db_instance_id" {
  description = "ID of the RDS instance"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "alarm_email" {
  description = "Email address for notifications"
  type        = string
  
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}