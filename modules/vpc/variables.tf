variable "vpc_name" {
  description = "ecsstack Vpc"
  type        = string
  default     = "ecs-stack-vpc"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
 
}

variable "public_subnets" {
  description = "Map of public subnets with their CIDR blocks and AZs"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  description = "Map of private subnets with their CIDR blocks and AZs"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
   
}

variable "enable_nat_gateway" {
  description = "Should NAT Gateway be enabled for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}