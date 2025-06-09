# Security Groups Module

This Terraform module creates security groups for a LAMP stack application in AWS.

## Features

- Creates security groups for ALB, web servers, and database
- Configurable ingress rules with sensible defaults
- Tagging support for all resources

## Usage

```hcl
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id

  name_prefix = "prod-lamp"
  
  web_ingress_cidr_blocks = ["0.0.0.0/0"]
  ssh_ingress_cidr_blocks = ["203.0.113.0/24"] # Your office IP
  database_ingress_cidr_blocks = ["10.0.0.0/16"]

  tags = {
    Environment = "production"
    Project     = "lamp-stack"
  }
}
```

## Outputs

- `alb_security_group_id`: The ID of the ALB security group
- `web_security_group_id`: The ID of the web server security group
- `database_security_group_id`: The ID of the database security group