# LAMP Stack on AWS with Terraform - Modules Documentation

## Overview

This Terraform project provides modular infrastructure for deploying a highly available LAMP (Linux, Apache, MySQL, PHP) stack on AWS. The infrastructure is divided into reusable modules that can be composed together.


![Architecture](media/lampstack_design.png)

## Module Structure

```
modules/
├── auto_scaling/       # Auto Scaling Group for web servers
├── compute/            # EC2 instances (alternative to ASG)
├── database/           # RDS MySQL database
├── load_balancer/      # Application Load Balancer
├── monitoring/         # CloudWatch alarms and metrics
├── security_groups/    # Security group definitions
└── vpc/                # VPC and networking components
```

## Module Details

### 1. VPC Module

**Purpose**: Creates the foundational networking infrastructure

**Features**:
- Configurable VPC CIDR block
- Public and private subnets across multiple AZs
- Internet Gateway for public subnets
- NAT Gateway for private subnets (optional)
- Route tables and associations

**Usage**:
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name = "prod-lamp-vpc"
  cidr_block = "10.0.0.0/16"
  
  public_subnets = {
    "public1" = { cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a" }
    "public2" = { cidr_block = "10.0.2.0/24", availability_zone = "us-east-1b" }
  }
  
  private_subnets = {
    "private1" = { cidr_block = "10.0.3.0/24", availability_zone = "us-east-1a" }
    "private2" = { cidr_block = "10.0.4.0/24", availability_zone = "us-east-1b" }
  }
}
```

### 2. Security Groups Module

**Purpose**: Defines network security rules

**Features**:
- ALB security group (HTTP/HTTPS)
- Web server security group (HTTP from ALB, SSH restricted)
- Database security group (MySQL from web servers)

**Usage**:
```hcl
module "security_groups" {
  source = "./modules/security_groups"
  
  vpc_id = module.vpc.vpc_id
  ssh_ingress_cidr_blocks = ["203.0.113.0/24"] # Restrict to your IP
}
```

### 3. Database Module

**Purpose**: Deploys managed MySQL database

**Features**:
- RDS MySQL instance
- Configurable storage and instance class
- Automatic backups
- Private subnet placement
- Secure password handling

**Usage**:
```hcl
module "database" {
  source = "./modules/database"
  
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.database_security_group_id]
  
  db_name = "lampdb"
  username = "admin"
  password = var.db_password # Pass via environment variable
}
```

### 4. Auto Scaling Module

**Purpose**: Manages web server fleet

**Features**:
- Launch template with user data for LAMP stack
- Auto scaling policies
- Integration with ALB
- Self-healing capabilities
- Configurable scaling thresholds

**Usage**:
```hcl
module "auto_scaling" {
  source = "./modules/auto_scaling"
  
  vpc_zone_identifier = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.web_security_group_id]
  target_group_arns = [module.load_balancer.target_group_arn]
  
  min_size = 2
  max_size = 4
  desired_capacity = 2
  
  db_host = module.database.db_instance_endpoint
  db_name = module.database.db_instance_name
  db_user = module.database.db_instance_username
  db_password = var.db_password
}
```

### 5. Load Balancer Module

**Purpose**: Distributes traffic to web servers

**Features**:
- Application Load Balancer
- HTTP listener
- Health checks
- Target group configuration

**Usage**:
```hcl
module "load_balancer" {
  source = "./modules/load_balancer"
  
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_security_group_id]
}
```

### 6. Monitoring Module

**Purpose**: Implements observability

**Features**:
- CPU utilization alarms
- ALB 5XX error monitoring
- RDS performance alarms
- SNS notifications

**Usage**:
```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  alb_arn = module.load_balancer.alb_arn
  db_instance_id = module.database.db_instance_id
  asg_name = module.auto_scaling.asg_name
  alarm_email = "alerts@example.com"
}
```

## Deployment Workflow

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Set required environment variables:
   ```bash
   export TF_VAR_db_password="your-secure-password"
   ```

3. Review execution plan:
   ```bash
   terraform plan
   ```

4. Deploy infrastructure:
   ```bash
   terraform apply
   ```

5. Access application:
   ```bash
   echo "Application URL: http://$(terraform output -raw alb_dns_name)"
   ```

## Maintenance

### Scaling
- Adjust `desired_capacity` in auto scaling module
- Modify RDS instance class as needed

### Updates
- Change `ami_name_filter` to update base image
- Modify launch template version for configuration changes

### Destruction
```bash
terraform destroy
```

## Best Practices

1. **Secrets Management**: Use AWS Secrets Manager for database credentials
2. **Backups**: Enable RDS automated backups with appropriate retention
3. **Monitoring**: Set up detailed CloudWatch dashboards
4. **CI/CD**: Integrate with pipeline for infrastructure updates
5. **Tagging**: Consistently tag all resources for cost tracking

## Troubleshooting

Common issues and solutions:

1. **User Data Failures**:
   - Check `/var/log/cloud-init-output.log`
   - Verify Docker container logs: `docker logs php-app`

2. **Database Connection Issues**:
   - Verify security group rules
   - Check RDS connectivity from EC2 instances

3. **Scaling Problems**:
   - Review CloudWatch metrics
   - Check Auto Scaling Group events

For additional support, refer to AWS documentation or Terraform registry examples.