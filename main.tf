# terraform {
#   cloud {
#     organization = "kryotech"

#     workspaces {
#       name = "ecs_stack_infranstructure"
#     }
#   }

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }



provider "aws" {
  region  = "eu-west-1"
  profile = "sandbox"
}

module "vpc" {
  source = "./modules/vpc"

  # Customize these values as needed
  vpc_name   = "ecs-production-vpc"
  cidr_block = "10.0.0.0/16"

  # You can override the default subnets if needed
  public_subnets = {
    "public-subnet-1" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-west-1a"
    }
    "public-subnet-2" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "eu-west-1b"
    }
  }

  private_subnets = {
    "private-subnet-1" = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "eu-west-1a"
    }
    "private-subnet-2" = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "eu-west-1b"
    }
  }

  tags = {
    Environment = "production"
    Project     = "ecs-stack"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}


module "security_groups" {
  source = "./modules/security_groups"
  ecs_security_group = module.ecs_alb.ecs_security_group
  vpc_id = module.vpc.vpc_id

  # Customize these as needed
  name_prefix = "prod-ecs"

  # Restrict SSH access in production!
  ssh_ingress_cidr_blocks = ["203.0.113.0/24"] # Replace with your IP

  tags = {
    Environment = "production"
    Project     = "ecs-stack"
  }
}

output "web_security_group_id" {
  value = module.security_groups.web_security_group_id
}

output "database_security_group_id" {
  value = module.security_groups.database_security_group_id
}

# output "dashboard_url" {
#   value       = module.monitoring.dashboard_url
#   description = "URL of the CloudWatch dashboard for monitoring"
# }

# Database Module
module "database" {
  source = "./modules/database"

  name_prefix        = "prod-ecs-db"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.database_security_group_id, module.ecs_alb.alb_security_group.id]

  username = "admin"
  password = var.db_password # Pass this via variables or environment

  tags = {
    Environment = "production"
    Project     = "ecs-stack"
  }
}


# Outputs
output "db_endpoint" {
  value     = module.database.db_instance_endpoint
  sensitive = true
}





module "ecs_alb" {
  source = "./modules/ecs_alb"

  app_name       = "ecsstack"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
  container_port = 80

}
module "ecs" {
  source = "./modules/ecs"

  # Common variables

  private_subnets = module.vpc.private_subnet_ids
  alb_listener    = module.ecs_alb.alb_listener
  ecr_repository_url = var.ecr_repository_url
  # Application-specific variables 
  security_group          = module.ecs_alb.ecs_security_group
  target_group_arn        = module.ecs_alb.target_group_arn
  ecs_task_execution_role = module.ecs_alb.ecs_task_execution_role
  log_group = module.ecs_alb.ecs_log_group
  app_name                = "ecsstack" 
  region                  = "eu-west-1"
  container_port          = 80
  host_port               = 80
  cpu                     = 256
  memory                  = 512
  desired_count           = 2
  db_host                 = module.database.db_instance_endpoint
  db_name                 = module.database.db_instance_name
  db_user                 = module.database.db_instance_username
  db_password             = var.db_password
}

output "website_url" {
  value = "http://${module.ecs_alb.alb_dns_name}"
}