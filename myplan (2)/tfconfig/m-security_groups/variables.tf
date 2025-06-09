variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to be used in resource names"
  type        = string
  default     = "lamp-stack"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "web_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access web ports (HTTP/HTTPS)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to instances"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production!
}

variable "database_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access database port"
  type        = list(string)
  default     = ["10.0.0.0/16"] # Default to VPC CIDR
}