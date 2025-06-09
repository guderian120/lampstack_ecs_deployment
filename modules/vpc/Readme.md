# VPC Module

This Terraform module creates a VPC with public and private subnets in AWS.

## Features

- Creates a VPC with configurable CIDR block
- Creates public and private subnets in specified availability zones
- Creates an Internet Gateway for public subnets
- Optionally creates NAT Gateway(s) for private subnets
- Configurable route tables for public and private subnets

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name = "my-lamp-vpc"
  cidr_block = "10.0.0.0/16"

  public_subnets = {
    "public-subnet-1" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    "public-subnet-2" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }

  private_subnets = {
    "private-subnet-1" = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "us-east-1a"
    }
    "private-subnet-2" = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "us-east-1b"
    }
  }

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "production"
    Project     = "lamp-stack"
  }
}
```

## Outputs

- `vpc_id`: The ID of the VPC
- `public_subnet_ids`: List of IDs of public subnets
- `private_subnet_ids`: List of IDs of private subnets
- `public_route_table_id`: ID of public route table
- `private_route_table_id`: ID of private route table
- `nat_gateway_id`: ID of the NAT Gateway (if enabled)
- `internet_gateway_id`: ID of the Internet Gateway