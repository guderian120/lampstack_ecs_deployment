variable "vpc_name" {
  description = "Lampstack Vpc"
  type        = string
  default     = "lamp-stack-vpc"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets with their CIDR blocks and AZs"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "public-subnet-1" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-west-1a"
    }
    "public-subnet-2" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "eu-west-1b"
    }
  }
}

variable "private_subnets" {
  description = "Map of private subnets with their CIDR blocks and AZs"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "private-subnet-1" = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "eu-west-1a"
    }
    "private-subnet-2" = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "eu-west-1b"
    }
  }
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