variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "lamp-web"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-03400c3b73b5086e9" # Amazon Linux 2 LTS
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.nano"
}

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be deployed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the instances"
  type        = list(string)
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "db_host" {
  description = "Database host endpoint"
  type        = string
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

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}