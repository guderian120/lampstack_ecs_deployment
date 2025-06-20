terraform {
  cloud {
    organization = "kryotech"

    workspaces {
      name = "lamp_stack_infranstructure"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}



provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "./modules/vpc"

  # Customize these values as needed
  vpc_name    = "lamp-production-vpc"
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
    Project     = "lamp-stack"
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

  vpc_id = module.vpc.vpc_id

  # Customize these as needed
  name_prefix = "prod-lamp"
  
  # Restrict SSH access in production!
  ssh_ingress_cidr_blocks = ["203.0.113.0/24"] # Replace with your IP
  
  tags = {
    Environment = "production"
    Project     = "lamp-stack"
  }
}

output "web_security_group_id" {
  value = module.security_groups.web_security_group_id
}

output "database_security_group_id" {
  value = module.security_groups.database_security_group_id
}

output "dashboard_url" {
  value = module.monitoring.dashboard_url
  description = "URL of the CloudWatch dashboard for monitoring"
}

# Database Module
module "database" {
  source = "./modules/database"

  name_prefix   = "prod-lamp-db"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.database_security_group_id]
  
  username = "admin"
  password = var.db_password # Pass this via variables or environment
  
  tags = {
    Environment = "production"
    Project     = "lamp-stack"
  }
}


# Outputs
output "db_endpoint" {
  value = module.database.db_instance_endpoint
  sensitive = true
}


module "load_balancer" { 
  source = "./modules/load_balancer"

  name_prefix        = "prod-lamp-alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_security_group_id]
  autoscaling_group_name = module.auto_scaling.asg_name
  
  tags = {
    Environment = "production"
    Project     = "lamp-stack"
  }
}




module "auto_scaling" {
  source = "./modules/auto_scaling"

  name_prefix        = "prod-lamp-asg"
  ami_id             = "ami-03400c3b73b5086e9" # Amazon Linux 2
  instance_type      = "t2.nano"
  vpc_zone_identifier = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.web_security_group_id,]
  target_group_arns  = [module.load_balancer.target_group_arn]
  key_name           = "my-key-pair"
  region = "eu-west-1"
  db_host     = module.database.db_instance_endpoint
  db_name     = module.database.db_instance_name
  db_user     = module.database.db_instance_username
  db_password = var.db_password
  iam_instance_profile_name = module.monitoring.monitoring_instance_profile

  min_size         = 1
  max_size         = 4
  desired_capacity = 1

  tags = {
    Environment = "production"
    Project     = "lamp-stack"
  }
}

module "monitoring" {
  source = "./modules/monitoring"

  name_prefix    = "prod-lamp-mon"
  db_instance_id = module.database.db_instance_identifier
  asg_name       = module.auto_scaling.asg_name
  alarm_email    = "realamponsah10@yahoo.com"
  region = "eu-west-1"
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_arn_suffix = module.load_balancer.alb_arn_suffix
  vpc_id = module.vpc.vpc_id
  ssh_ingress_cidr_blocks = ["0.0.0.0/0"]
    tags = {
    Environment = "production"
    Project     = "lamp-stack"
  }
}

output "website_url" {
  value = "http://${module.load_balancer.alb_dns_name}"
}