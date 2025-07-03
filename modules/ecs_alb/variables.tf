variable "app_name" {
  description = "name of application"
  type = string
}

variable "public_subnets" {
    description = "private subnets"
    type = list
}


variable "vpc_id" {
    description = "VPC ID"
}

variable "container_port" {
    description = "container port"
    type = number
}

variable "region" {
    description = "default region"
    default = "eu-west-1"
}