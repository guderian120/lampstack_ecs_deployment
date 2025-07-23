
# ================================ PROVIDER INFORMATION ========================================================= #
# Primary Region (eu-west-1 - Ireland)
provider "aws" {
  region  = "eu-west-1"
  profile = "sandbox"
  alias   = "primary"
}

# Secondary Region (eu-central-1 - London)
provider "aws" {
  region  = "eu-central-1"
  profile = "sandbox"
  alias   = "secondary"
}
# =================================================================================================================#


#========================================= PRIMARY REGION INFRA ===================================================#
module "primary_vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.primary
  }
  # Customize these values as needed
  vpc_name   = "ecs-production-vpc"
  cidr_block = "10.0.0.0/16"

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



module "primary_security_groups" {
  source = "./modules/security_groups"
  providers = {
    aws = aws.primary
  }
  ecs_security_group = module.primary_ecs_alb.ecs_security_group
  vpc_id             = module.primary_vpc.vpc_id

  name_prefix = "prod-ecs"

  # Restrict SSH access in production!
  ssh_ingress_cidr_blocks = ["203.0.113.0/24"] # Replace with your IP

  tags = {
    Environment = "production"
    Project     = "ecs-stack"
  }
}


# module "primary_kms" {
#   source = "./modules/kms" 
#   region = var.primary_region
#   account_id = var.account_id
  # providers = {
  #   aws = aws.primary
  # }

# }
# Database Module
module "primary_database" {
  source = "./modules/database"
  providers = {
    aws = aws.primary
  }
  name_prefix        = "prod-ecs-db"
  subnet_ids         = module.primary_vpc.private_subnet_ids
  security_group_ids = [module.primary_security_groups.database_security_group_id]
  kms_key_arn        = var.kms_key_arn
  engine             = "mysql"
  engine_version     = "5.7"
  instance_class     = "db.t3.medium"
  allocated_storage  = 50
  db_name            = "mydatabase"
  username           = "admin"
  password           = var.db_password

  backup_retention_period = 7
  multi_az                = true # Enable for production
  is_replica              = false

  depends_on = [
    module.primary_vpc.nat_gateway_id,
    module.primary_vpc.private_subnet_ids # Your private route associations
  ]
}






module "primary_ecs_alb" {
  source = "./modules/ecs_alb"
  providers = {
    aws = aws.primary
  }
  app_name       = "ecsstack"
  vpc_id         = module.primary_vpc.vpc_id
  public_subnets = module.primary_vpc.public_subnet_ids
  container_port = 80

}
module "primary_ecs" {
  source = "./modules/ecs"
  providers = {
    aws = aws.primary
  }
  # Common variables 
  private_subnets    = module.primary_vpc.private_subnet_ids
  alb_listener       = module.primary_ecs_alb.alb_listener
  ecr_repository_url = var.ecr_repository_url
  # Application-specific variables 
  security_group          = module.primary_ecs_alb.ecs_security_group
  target_group_arn        = module.primary_ecs_alb.target_group_arn
  ecs_task_execution_role = module.primary_ecs_alb.role_arn
  log_group               = module.primary_ecs_alb.ecs_log_group
  app_name                = "ecsstack"
  region                  = "eu-west-1"
  container_port          = 80
  host_port               = 80
  cpu                     = 256
  memory                  = 512
  desired_count           = 2
  db_host                 = module.primary_database.db_instance_endpoint
  db_name                 = module.primary_database.db_instance_name
  db_user                 = module.primary_database.db_instance_username
  db_password             = var.db_password
}

#======================================================================================================================#
#==================================================== CROSS REGIONAL FAILOVER RESOURCES ===============================#

module "sns" {
  source = "./modules/sns"
  providers = {
    aws = aws.primary
  }

}
module "fail_over_resources" {
  source              = "./modules/fail_over_resources"
    providers = {
    aws = aws.primary
  }
  sns_topic_arn       = module.sns.sns_topic_arn
  alb_arn             = module.primary_ecs_alb.alb_arn
  DR_ALB_LISTENER_ARN = module.dr_ecs_alb.alb_listener.arn
  depends_on = [module.primary_ecs_alb, module.primary_ecs.ecs_service]
  target_group_arn = module.primary_ecs_alb.target_group_name
  service_name = module.primary_ecs.ecs_service
  cluster_name = module.primary_ecs.cluster_name
}


#=======================================SECONDARY RESOURCE INFRA =======================================================#


# Secondary VPC (Minimal)
module "dr_vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.secondary
  }

  vpc_name   = "dr-ecs-vpc"
  cidr_block = "10.1.0.0/16"

  # Only 1 subnet per type for DR
  public_subnets = {
    "public-subnet-1" = {
      cidr_block        = "10.1.1.0/24"
      availability_zone = "eu-central-1a"
    }
    "public-subnet-2" = {
      cidr_block        = "10.1.2.0/24"
      availability_zone = "eu-central-1b"
    }

  }

  private_subnets = {
    "private-subnet-1" = {
      cidr_block        = "10.1.3.0/24"
      availability_zone = "eu-central-1a"
    }
    "private-subnet-2" = {
      cidr_block        = "10.1.4.0/24"
      availability_zone = "eu-central-1b"
    }
  }
}

# Secondary Security Groups (Minimal)
module "secondary_security_groups" {
  source = "./modules/security_groups"
  providers = {
    aws = aws.secondary
  }
  ecs_security_group = module.dr_ecs_alb.ecs_security_group
  vpc_id             = module.dr_vpc.vpc_id
  # Minimal SG rules for DR
}

# Database Replica (Pilot Light)
module "dr_database" {
  source = "./modules/database"
  providers = {
    aws = aws.secondary
  }
  name_prefix = "dr-ecs-db"

  subnet_ids         = module.dr_vpc.private_subnet_ids
  security_group_ids = [module.secondary_security_groups.database_security_group_id]
  multi_az           = true
  instance_class     = "db.t3.small" # Smaller instance for DR
  allocated_storage  = null          # Less storage than primary
  kms_key_arn        = var.kms_replica_arn
  # Replica-specific configuration
  is_replica          = true
  replicate_source_db = module.primary_database.db_instance_arn

  # These are ignored for replicas but still required by the module
  engine         = "mysql"
  engine_version = "5.7"
  db_name        = "mydatabase"
  username       = "admin"
  password       = var.db_password
}

module "dr_ecs_alb" {
  source = "./modules/ecs_alb"
  providers = {
    aws = aws.secondary
  }
  app_name          = "ecsstack"
  vpc_id            = module.dr_vpc.vpc_id
  public_subnets    = module.dr_vpc.public_subnet_ids
  container_port    = 80
  create_role       = false
  existing_role_arn = module.primary_ecs_alb.role_arn
}


module "dr_ecs" {
  source = "./modules/ecs"
  providers = {
    aws = aws.secondary
  }
  # Common variables 
  private_subnets    = module.dr_vpc.private_subnet_ids
  alb_listener       = module.dr_ecs_alb.alb_listener
  ecr_repository_url = var.ecr_repository_url
  is_dr              = true
  # Application-specific variables 
  security_group          = module.dr_ecs_alb.ecs_security_group
  target_group_arn        = module.dr_ecs_alb.target_group_arn
  ecs_task_execution_role = module.dr_ecs_alb.role_arn
  log_group               = module.dr_ecs_alb.ecs_log_group
  app_name                = "dr_ecsstack"
  region                  = var.dr_region
  container_port          = 80
  host_port               = 80
  cpu                     = 256
  memory                  = 512
  desired_count           = 0
  db_host                 = module.dr_database.db_instance_endpoint
  db_name                 = module.dr_database.db_instance_name
  db_user                 = module.dr_database.db_instance_username
  db_password             = var.db_password
}
