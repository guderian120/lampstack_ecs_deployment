variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "lamp-alb"
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

# variable "target_instance_ids" {
#   description = "List of target instance IDs for the ALB"
#   type        = list(string)
# }

variable "autoscaling_group_name" {
  type        = string
  description = "Name of the Auto Scaling Group to attach to the target group"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}