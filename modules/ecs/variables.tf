variable "app_name" {
  description = "name of application"
}

variable "container_port" {
    description = "container port"
    type = number
}

variable "host_port" {
    description = "host port"
    type = number
}
variable "desired_count" {
    description = "desired container count"
    type = number
}
variable "private_subnets" {
    description = "private subnets"
    type = list
}
variable "cpu" {
    description = "cpu"
    type = number
}

variable "memory" {
    description = "memory"
    type = number
}


variable "db_host" {
  description = "Database host endpoint"
  type        = string
}

variable "ecr_repository_url" {
  description = "ecr repository url"  
  type = string
  
}
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
variable "log_group" {
  description = "Log group for ecs"
  type = string
}

variable "security_group" {
    description = "security group for ecs"
  
}

variable "target_group_arn" {
    description = "target group arn"
  
}

variable "region" {
  description = "aws region"
}

variable "alb_listener" {
  description = "alb listener"
}

variable "ecs_task_execution_role" {
  description = "task execution role"
}