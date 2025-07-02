
# LAMP Stack Deployment on AWS with ECS and ALB

## Table of Contents
1. [Project Overview](#project-overview)
2. [Key Features](#key-features)
3. [Prerequisites](#prerequisites)
4. [Local Development Setup](#local-development-setup)
   - [Terraform Cloud Configuration](#terraform-cloud-configuration)
   - [Local Machine Setup](#local-machine-setup)
5. [Architecture Components](#architecture-components)
6. [Deployment Workflows](#deployment-workflows)
   - [Terraform Cloud CI/CD](#terraform-cloud-cicd)
   - [Local Deployment](#local-deployment)
7. [Module Documentation](#module-documentation)
8. [Maintenance Guide](#maintenance-guide)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting) 
11. [Support](#support)

---
![Demo](media/lamp_demo.gif)

## Project Overview <a name="project-overview"></a>

This project automates the deployment of a highly available LAMP (Linux, Apache, MySQL, PHP) stack on AWS ECS (Elastic Container Service), with integrated CI/CD through Terraform Cloud. The infrastructure follows AWS Well-Architected Framework principles and features automatic deployments on code changes. For detailed documentations on the PHP source code visit [![PHP DOCS](https://img.shields.io/badge/-Live%20Demo-green?style=for-the-badge)](https://github.com/guderian120/lamp_stack_application)


## 🔗 Live Deployment

The application is currently deployed and accessible at:  
[![Live Demo](https://img.shields.io/badge/-Live%20Demo-blue?style=for-the-badge)](http://ecsstack-alb-856037561.eu-west-1.elb.amazonaws.com/index.php)

## Resource Map
![Resource Map](media/ecs_resource_map.png)


## Key Features <a name="key-features"></a>

- **Terraform Cloud CI/CD**: Automatic plan and apply on code pushes
- **Highly Available Architecture**: Multi-AZ deployment with ECS
- **Containerized Workloads**: Dockerized LAMP stack deployment
- **GitOps Workflow**: Infrastructure changes via Git repository
- **Remote State Management**: Secure state storage in Terraform Cloud
- **Auto-scaling Service**: ECS Service with application auto-scaling
- **Managed Database**: Amazon RDS MySQL with automated backups
- **Secure Networking**: ECS tasks in private subnets with ALB ingress
- **Comprehensive Monitoring**: CloudWatch alarms and SNS notifications

## Prerequisites <a name="prerequisites"></a>

### Terraform Cloud Requirements
- Terraform Cloud account (free tier available)
- GitHub/GitLab/Bitbucket account for VCS integration
- Organization created in Terraform Cloud

### AWS Requirements
- AWS account with administrator permissions
- IAM user with programmatic access
- AWS CLI v2 installed
- ECR repository for container images

### Local Development Requirements
- Terraform v1.0+ installed
- Docker installed for local container testing
- Git client
- Text editor (VS Code recommended)

## Local Development Setup <a name="local-development-setup"></a>

### Terraform Cloud Configuration <a name="terraform-cloud-configuration"></a>

1. **Create a Terraform Cloud Workspace**
   - Log in to [Terraform Cloud](https://app.terraform.io)
   - Navigate to your organization
   - Click "New workspace"
   - Select "Version control workflow"
   - Connect your VCS provider (GitHub/GitLab/Bitbucket)
   - Choose your repository containing this project
   - Set workspace name (e.g., "prod-ecs-lamp-stack")

2. **Configure Workspace Variables**
   Add these variables in your Terraform Cloud workspace:

   | Variable | Category | Description |
   |----------|----------|-------------|
   | `AWS_ACCESS_KEY_ID` | Environment | Your AWS access key |
   | `AWS_SECRET_ACCESS_KEY` | Environment | Your AWS secret key |
   | `TF_VAR_db_password` | Terraform | Database password (mark as sensitive) |
   | `TF_VAR_region` | Terraform | AWS region (e.g., "us-east-1") |
   | `TF_VAR_ecr_repository_url` | Terraform | ECR repository URL for container images |

3. **Configure Execution Settings**
   - Set execution mode to "Remote"
   - Enable "Auto apply" for automatic deployments (optional)
   - Configure VCS triggers to run on pull requests (recommended)

### Local Machine Setup <a name="local-machine-setup"></a>

1. **Clone the Repository**
   ```bash
   git clone -b ecs-feature https://github.com/guderian120/lamp_stack_infranstructure
   cd lamp_stack_infranstructure
   ```

2. **Configure Terraform Backend**
   Ensure your `backend.tf` is configured for Terraform Cloud:
   ```hcl
   terraform {
     backend "remote" {
       organization = "your-org-name"
       
       workspaces {
         name = "prod-ecs-lamp-stack"
       }
     }
   }
   ```

3. **Build and Push Docker Image**
   ```bash
   cd .. # come out of the terraform configurations folder
   git clone https://github.com/guderian120/lamp_stack_application #clone the php code
   cd lamp_stack_application
   docker build -t lamp-stack ./docker
   aws ecr get-login-password | docker login --username AWS --password-stdin YOUR_ECR_URL
   docker tag lamp-stack:latest YOUR_ECR_URL/lamp-stack:latest
   docker push YOUR_ECR_URL/lamp-stack:latest
   ```

4. **Initialize Terraform**
   ```bash
   cd .. # come out of the php code directory
   cd lampstack_infranstructure # enter the terraform configurations folder
   terraform init #initialize the directory
   ```

5. **Configure Local Variables**
   Create a `terraform.tfvars` file with your configuration:
   ```hcl
   environment = "prod"
   region = "eu-west-1"
   db_password = "your-secure-password"
   ecr_repository_url = "your-account-id.dkr.ecr.region.amazonaws.com/your-repo"
   ```

## Architecture Components <a name="architecture-components"></a>

The solution consists of the following core components:

1. **Networking Layer**:
   - VPC with public and private subnets across multiple AZs
   - Internet Gateway and NAT Gateway for connectivity
   - Route tables for traffic management

2. **Compute Layer**:
   - ECS Cluster with Fargate launch type
   - ECS Service with task definition for LAMP stack
   - Application Load Balancer with health checks

3. **Data Layer**:
   - Amazon RDS MySQL instance
   - Automated backups and maintenance

4. **Security Layer**:
   - Security groups restricting traffic flow
   - IAM roles with least privilege
   - ECS tasks running in private subnets

5. **Monitoring Layer**:
   - CloudWatch alarms for performance metrics
   - SNS notifications for critical events
   - Container insights for ECS monitoring

## Deployment Workflows <a name="deployment-workflows"></a>

### Terraform Cloud CI/CD <a name="terraform-cloud-cicd"></a>

1. **Standard Workflow**
   - Push changes to your connected repository
   - Terraform Cloud detects VCS changes
   - Automatic `terraform plan` executes
   - Manual approval required (unless auto-apply enabled)
   - Changes are deployed to AWS

2. **Image Update Workflow**
   - Update Docker image and push to ECR
   - Update `container_image` variable in Terraform
   - Terraform Cloud triggers deployment of new task definition

### Local Deployment <a name="local-deployment"></a>

1. **Development Workflow**
   ```bash
   # Create feature branch
   git checkout -b feature/ecs-update
   
   # Make changes and test locally
   terraform plan
   
   # Commit and push changes
   git add .
   git commit -m "Update ECS task memory limits"
   git push origin feature/ecs-update
   ```

2. **Apply Changes**
   ```bash
   # Review changes
   terraform plan
   
   # Apply changes (if not using CI/CD)
   terraform apply
   ```

3. **Access the Application**
   ```bash
   terraform output -raw alb_dns_name
   ```

## Module Documentation <a name="module-documentation"></a>

The infrastructure is organized into reusable Terraform modules:

| Module | Description | Key Features |
|--------|-------------|--------------|
| `vpc` | Networking foundation | VPC, subnets, gateways, route tables |
| `security_groups` | Network security | ALB, ECS, and database security groups |
| `database` | Managed MySQL database | RDS instance, backups, private placement |
| `ecs` | Container orchestration | Cluster, service, task definition, scaling |
| `load_balancer` | Traffic distribution | ALB, target groups, health checks |
| `monitoring` | Observability | CloudWatch alarms, SNS notifications |

## Maintenance Guide <a name="maintenance-guide"></a>

### Scaling Operations
- **Service Scaling**: Adjust `desired_count` or configure auto-scaling policies
- **Task Resources**: Modify CPU/memory in task definition

### Updates
1. **Container Updates**:
   - Push new image to ECR
   - Update `container_image` tag in variables

2. **Configuration Changes**:
   - Update task definition parameters
   - Apply changes through Terraform Cloud CI/CD

### Backup and Recovery
- **Database Backups**: Managed by RDS with configurable retention
- **State Management**: Automatic state versioning in Terraform Cloud

### Destruction
To remove all resources through Terraform Cloud:
1. Queue destroy plan in workspace
2. Confirm destruction

## Best Practices <a name="best-practices"></a>

1. **Security**:
   - Use Terraform Cloud's sensitive variable handling
   - Implement Sentinel policies for governance
   - Enable VPC flow logs for traffic monitoring

2. **CI/CD Optimization**:
   - Separate workspaces for dev/stage/prod
   - Implement image scanning in ECR
   - Use pre-commit hooks for validation

3. **Cost Management**:
   - Right-size Fargate task resources
   - Implement auto-scaling policies
   - Clean up unused resources

## Troubleshooting <a name="troubleshooting"></a>

| Issue | Solution |
|-------|----------|
| ECS tasks not starting | Check task definition and CloudWatch logs |
| ALB health check failures | Verify container health check endpoint |
| Terraform Errors | Check the main.tf file for configuration issues |
| Runs not triggering | Verify VCS connection in Terraform Cloud |
| Authentication errors | Verify AWS credentials in workspace variables |

## Support <a name="support"></a>

For additional assistance:
- [Terraform Cloud Documentation](https://www.terraform.io/docs/cloud)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/best-practices.html)
- Repository Issues: https://github.com/guderian120/lamp_stack_infranstructure/issues

For production deployments, consider HashiCorp's paid support options for Terraform Cloud.