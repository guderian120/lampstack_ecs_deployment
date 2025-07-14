
# AWS ECS Pilot Light DR LAMP Stack Solution Documentation

## Table of Contents

1.  **Introduction**
      * 1.1 Purpose
      * 1.2 Solution Overview
      * 1.3 Disaster Recovery Strategy (Pilot Light)
      * 1.4 Project Overview & Key Features
2.  **Architecture Overview**
      * 2.1 Primary Region Architecture (eu-west-1)
      * 2.2 Disaster Recovery (DR) Region Architecture (eu-central-1)
      * 2.3 Network Topology
      * 2.4 Data Flow
      * 2.5 Core Architecture Components
3.  **Components and Services**
      * 3.1 Virtual Private Cloud (VPC)
      * 3.2 Elastic Container Service (ECS)
      * 3.3 Relational Database Service (RDS)
      * 3.4 Application Load Balancer (ALB)
      * 3.5 Security Groups
      * 3.6 Amazon Elastic Container Registry (ECR)
      * 3.7 Amazon CloudWatch Logs
4.  **Deployment**
      * 4.1 Prerequisites
      * 4.2 Infrastructure as Code (Terraform)
      * 4.3 Deployment Workflows
      * 4.4 Key Outputs
5.  **Disaster Recovery Procedures**
      * 5.1 Failover Process
      * 5.2 Failback Process
      * 5.3 RTO/RPO Considerations
6.  **Monitoring and Logging**
      * 6.1 Application Logging
      * 6.2 Infrastructure Monitoring
7.  **Security Considerations**
      * 7.1 Network Security
      * 7.2 IAM Roles and Permissions
      * 7.3 Data Encryption
8.  **Maintenance and Operations**
      * 8.1 Scaling Operations
      * 8.2 Updates
      * 8.3 Backup and Recovery
      * 8.4 Destruction
9.  **Best Practices & Troubleshooting**
      * 9.1 Best Practices
      * 9.2 Troubleshooting
10. **Support**
      * 10.1 Live Deployment
      * 10.2 Further Assistance

-----

## 1\. Introduction

### 1.1 Purpose

This document provides comprehensive technical documentation for a highly available LAMP (Linux, Apache, MySQL, PHP/Perl/Python) stack solution deployed on Amazon Web Services (AWS) using Amazon Elastic Container Service (ECS) and other managed services. It details the architecture, components, deployment, and particularly the pilot light disaster recovery (DR) strategy implemented across multiple AWS regions.

### 1.2 Solution Overview

The solution provides a robust and scalable environment for hosting web applications. It leverages AWS Fargate for serverless container execution, an Application Load Balancer (ALB) for traffic distribution, and Amazon RDS for database services. The primary infrastructure resides in `eu-west-1`, with a pilot light DR setup in `eu-central-1` to ensure business continuity in case of a regional outage.

### 1.3 Disaster Recovery Strategy (Pilot Light)

A "Pilot Light" disaster recovery strategy has been implemented. This approach maintains a minimal, "pilot light" version of the infrastructure in a secondary (DR) region, ready to be quickly scaled up to full capacity in the event of a disaster affecting the primary region.

Key characteristics of this strategy in this solution include:

  * **Database Replication:** The primary RDS database asynchronously replicates data to a read replica in the DR region. This keeps the DR database continuously updated with minimal data loss (low RPO).
  * **Scaled-Down Compute:** The ECS services in the DR region are configured with a `desired_count` of `0`, meaning no containers are actively running. This minimizes costs in the DR region while allowing rapid scaling during failover.
  * **Pre-provisioned Infrastructure:** VPCs, subnets, load balancers, ECS clusters, and task definitions are fully deployed in the DR region, enabling quick activation of compute resources.

This strategy balances cost-efficiency with a relatively low Recovery Time Objective (RTO) and Recovery Point Objective (RPO).

### 1.4 Project Overview & Key Features

This project automates the deployment of a highly available LAMP stack on AWS ECS, with integrated CI/CD through Terraform Cloud. The infrastructure follows AWS Well-Architected Framework principles and features automatic deployments on code changes. For detailed documentation on the PHP source code, please visit the [PHP DOCS](https://github.com/guderian120/lamp_stack_application).

**Key Features:**

  * **Terraform Cloud CI/CD**: Automatic plan and apply on code pushes.
  * **Highly Available Architecture**: Multi-AZ deployment with ECS.
  * **Containerized Workloads**: Dockerized LAMP stack deployment.
  * **GitOps Workflow**: Infrastructure changes via Git repository.
  * **Remote State Management**: Secure state storage in Terraform Cloud.
  * **Auto-scaling Service**: ECS Service with application auto-scaling.
  * **Managed Database**: Amazon RDS MySQL with automated backups.
  * **Secure Networking**: ECS tasks in private subnets with ALB ingress.
  * **Comprehensive Monitoring**: CloudWatch alarms and SNS notifications.

## 2\. Architecture Overview

The solution is split into two distinct AWS regions: a primary active region and a secondary passive (pilot light) DR region.

### 2.1 Primary Region Architecture (eu-west-1)

The primary region hosts the active LAMP stack.

  * **VPC:** A dedicated Virtual Private Cloud (VPC) provides an isolated network environment.
  * **Subnets:** It includes public subnets for the Application Load Balancer (ALB) and private subnets for ECS tasks and the RDS database. NAT Gateways are used to enable outbound internet access for resources in private subnets.
  * **Application Load Balancer (ALB):** An internet-facing ALB distributes incoming web traffic (HTTP on port 80) across ECS tasks.
  * **ECS Cluster (Fargate):** An Amazon ECS cluster running on AWS Fargate hosts the LAMP stack application containers. Tasks are deployed in private subnets.
  * **RDS Database:** An Amazon RDS MySQL instance serves as the primary database, residing in private subnets for enhanced security.

**Primary Region Key Endpoints/IDs:**

  * **Primary Website URL:** `http://ecsstack-alb-1662418084.eu-west-1.elb.amazonaws.com`
  * **Primary DB Endpoint:** `prod-ecs-db.cda62s0o6etz.eu-west-1.rds.amazonaws.com:3306`
  * **Primary VPC ID:** `vpc-01f3a436e50627a98`
  * **Primary Public Subnet IDs:** `subnet-0805e63676f24c1c7`, `subnet-0da536604092cc54b`
  * **Primary Private Subnet IDs:** `subnet-0fdb1f1db3e83953a`, `subnet-053d4b419294fa3a8`
  * **Primary Database Security Group ID:** `sg-0cf3fad16141aa54b`
  * **Primary Web Security Group ID:** `sg-05e427059b590fd6c`

### 2.2 Disaster Recovery (DR) Region Architecture (eu-central-1)

The DR region holds the pilot light infrastructure.

  * **VPC:** A separate VPC in the DR region mirrors the network structure of the primary, including public and private subnets.
  * **Application Load Balancer (ALB):** An internet-facing ALB is deployed but remains passive, awaiting activation.
  * **ECS Cluster (Fargate):** An ECS cluster and associated task definitions are pre-provisioned. The ECS service `desired_count` is set to `0`, meaning no Fargate tasks are running during normal operations.
  * **RDS Read Replica:** An Amazon RDS MySQL read replica continuously synchronizes data from the primary database, ensuring data availability with minimal lag. This replica can be promoted to a standalone primary database during failover.

**DR Region Key Endpoints/IDs:**

  * **DR DB Endpoint:** `dr-ecs-db.c5iksmi6c35p.eu-central-1.rds.amazonaws.com:3306`
  * **DR ALB DNS Name:** `ecsstack-alb-1121063250.eu-central-1.elb.amazonaws.com` (This would become the active endpoint after failover)
  * **DR VPC ID:** `vpc-0dc523f2e643f8fea`
  * **DR Database Security Group ID:** `sg-02cce8dcab003fdad`
  * **DR ALB Security Group ID:** `sg-06e2d5454515254c3`
  * **DR ECS Security Group ID:** `sg-0cdaa177d37044f5e`
  * **DR ECS Cluster ARN:** `arn:aws:ecs:eu-central-1:288761743924:cluster/dr_ecsstack-cluster`
  * **DR ECS Service ARN:** `arn:aws:ecs:eu-central-1:288761743924:service/dr_ecsstack-cluster/dr_ecsstack-service`

### 2.3 Network Topology

Both regions employ a similar network topology:

  * **Public Subnets:** Hosts internet-facing resources like ALBs.
  * **Private Subnets:** Hosts application containers (ECS Fargate tasks) and databases (RDS instances).
  * **NAT Gateway (Primary):** Provides outbound internet access from private subnets in the primary region. (Assumed, as EIP for NAT is present in outputs).
  * **Internet Gateway:** Enables communication between the VPC and the internet.

### 2.4 Data Flow

1.  **Primary Region:** User requests reach the Primary ALB, which forwards them to ECS Fargate tasks running the LAMP application. The application connects to the Primary RDS MySQL database.
2.  **Cross-Region Replication:** The Primary RDS MySQL instance asynchronously replicates data to the DR RDS MySQL Read Replica in `eu-central-1`.
3.  **DR Region (During Failover):** In a DR scenario, DNS records are updated to point to the DR ALB. The DR RDS Read Replica is promoted to a standalone instance, and the DR ECS service is scaled up to handle traffic.

### 2.5 Core Architecture Components

The solution's infrastructure is built upon the following layers and services:

1.  **Networking Layer**:
      * VPC with public and private subnets across multiple AZs.
      * Internet Gateway and NAT Gateway for connectivity.
      * Route tables for traffic management.
2.  **Compute Layer**:
      * ECS Cluster with Fargate launch type.
      * ECS Service with task definition for LAMP stack.
      * Application Load Balancer with health checks.
3.  **Data Layer**:
      * Amazon RDS MySQL instance.
      * Automated backups and maintenance.
4.  **Security Layer**:
      * Security groups restricting traffic flow.
      * IAM roles with least privilege.
      * ECS tasks running in private subnets.
5.  **Monitoring Layer**:
      * CloudWatch alarms for performance metrics.
      * SNS notifications for critical events.
      * Container insights for ECS monitoring.

## 3\. Components and Services

This section details the AWS services and key components configured for the LAMP stack solution.

### 3.1 Virtual Private Cloud (VPC)

  * **Purpose:** Provides an isolated virtual network in AWS for your resources.
  * **Configuration:**
      * Separate VPCs in `eu-west-1` (Primary) and `eu-central-1` (DR).
      * Each VPC is configured with public and private subnets across multiple Availability Zones for high availability within the region.
      * Primary VPC has an Internet Gateway and NAT Gateway for outbound connectivity from private subnets.

### 3.2 Elastic Container Service (ECS)

  * **Purpose:** Orchestrates Docker containers using AWS Fargate, removing the need to manage EC2 instances.
  * **Configuration:**
      * **ECS Clusters:** `ecsstack-cluster` (Primary, assumed from context) and `dr_ecsstack-cluster` (DR).
      * **Task Definitions:** Define the application container specifications.
          * **Image:** `288761743924.dkr.ecr.eu-west-1.amazonaws.com/lampstack:latest` (This indicates an ECR repository in `eu-west-1` is used for the application image).
          * **CPU/Memory:** `256 CPU` / `512 MB` for Fargate tasks.
          * **Network Mode:** `awsvpc`.
          * **Environment Variables:** `DB_HOST`, `DB_NAME`, `DB_PASS`, `DB_USER` (for database connectivity).
          * **Port Mappings:** Container port `80` mapped to host port `80` (for HTTP traffic).
          * **Log Configuration:** Sends container logs to CloudWatch Logs group `/ecs/ecsstack`.
      * **ECS Services:**
          * Manages the desired number of running tasks.
          * Integrated with Application Load Balancers.
          * **Primary Service:** Actively running `desired_count` (assumed \> 0).
          * **DR Service:** `dr_ecsstack-service` configured with `desired_count: 0` to conserve costs in pilot light mode, ready to be scaled up.

### 3.3 Relational Database Service (RDS)

  * **Purpose:** Provides a managed MySQL database instance.
  * **Configuration:**
      * **Primary Database:** `prod-ecs-db` (MySQL 5.7, `db.t3.small`, 50GB storage, encrypted, not publicly accessible). Resides in private subnets in `eu-west-1`.
      * **DR Database:** `dr-ecs-db` (MySQL 5.7, `db.t3.small`, 50GB storage, encrypted, not publicly accessible). This is configured as a read replica of `prod-ecs-db` in `eu-central-1`. It also resides in private subnets.
      * **Subnet Groups:** Dedicated DB Subnet Groups for placing RDS instances into specified private subnets.

### 3.4 Application Load Balancer (ALB)

  * **Purpose:** Distributes incoming application traffic to multiple targets, such as ECS tasks.
  * **Configuration:**
      * **Primary ALB:** Internet-facing, listening on HTTP port 80, forwarding traffic to the ECS tasks.
      * **DR ALB:** `ecsstack-alb` (DR region `eu-central-1`), internet-facing, listening on HTTP port 80, forwarding traffic to the DR ECS service target group. While active, no tasks are running until failover.
      * **Target Groups:** Health checks configured to monitor the application containers (HTTP on `/`).

### 3.5 Security Groups

  * **Purpose:** Act as virtual firewalls to control inbound and outbound traffic to instances and network interfaces.
  * **Configuration:**
      * **ALB Security Group (Primary & DR):** Allows inbound HTTP (port 80) traffic from anywhere (`0.0.0.0/0`).
      * **ECS Security Group (Primary & DR):** Allows inbound traffic on container ports (e.g., port 80) only from the associated ALB's security group. This ensures only traffic routed through the ALB can reach the ECS tasks.
      * **Database Security Group (Primary & DR):** Allows inbound traffic on the MySQL port (3306) only from the associated ECS security group, preventing direct internet access to the database.

### 3.6 Amazon Elastic Container Registry (ECR)

  * **Purpose:** A fully managed Docker container registry.
  * **Configuration:** The `lampstack:latest` application image is stored in an ECR repository, allowing ECS to pull the images for task deployment. (Implied from the task definition `image` field).

### 3.7 Amazon CloudWatch Logs

  * **Purpose:** Centralized logging for applications and AWS services.
  * **Configuration:** ECS tasks are configured to send their logs to a dedicated CloudWatch Log Group named `/ecs/ecsstack` in each region. This facilitates centralized log collection and analysis.

## 4\. Deployment

The entire infrastructure for both primary and DR regions is defined and managed using Terraform.

### 4.1 Prerequisites

To deploy and manage this solution, ensure the following requirements are met:

**Terraform Cloud Requirements:**

  * Terraform Cloud account (free tier available).
  * GitHub/GitLab/Bitbucket account for VCS integration.
  * Organization created in Terraform Cloud.

**AWS Requirements:**

  * AWS account with administrator permissions.
  * IAM user with programmatic access.
  * AWS CLI v2 installed.
  * ECR repository for container images (e.g., `288761743924.dkr.ecr.eu-west-1.amazonaws.com/lampstack`).

**Local Development Requirements:**

  * Terraform v1.0+ installed.
  * Docker installed for local container testing.
  * Git client.
  * Text editor (VS Code recommended).

### 4.2 Infrastructure as Code (Terraform)

The project uses Terraform to automate the provisioning and management of the AWS infrastructure. The provided state file indicates the use of modules for logical grouping of resources (e.g., `module.dr_database`, `module.dr_ecs`, `module.dr_ecs_alb`, `module.dr_vpc`).

The infrastructure is organized into reusable Terraform modules:

| Module | Description | Key Features |
|--------|-------------|--------------|
| `vpc` | Networking foundation | VPC, subnets, gateways, route tables |
| `security_groups` | Network security | ALB, ECS, and database security groups |
| `database` | Managed MySQL database | RDS instance, backups, private placement |
| `ecs` | Container orchestration | Cluster, service, task definition, scaling |
| `load_balancer` | Traffic distribution | ALB, target groups, health checks |
| `monitoring` | Observability | CloudWatch alarms, SNS notifications |

### 4.3 Deployment Workflows

This solution supports both CI/CD driven deployments via Terraform Cloud and local development workflows.

#### 4.3.1 Terraform Cloud CI/CD

This is the recommended workflow for production deployments, leveraging Terraform Cloud for automated and secure infrastructure changes.

1.  **Create a Terraform Cloud Workspace:**

      * Log in to [Terraform Cloud](https://app.terraform.io).
      * Navigate to your organization.
      * Click "New workspace" and select "Version control workflow."
      * Connect your VCS provider (GitHub/GitLab/Bitbucket) and choose your repository.
      * Set workspace name (e.g., "prod-ecs-lamp-stack").

2.  **Configure Workspace Variables:**
    Add these variables in your Terraform Cloud workspace. Mark sensitive variables accordingly.

    | Variable | Category | Description |
    |----------|----------|-------------|
    | `AWS_ACCESS_KEY_ID` | Environment | Your AWS access key |
    | `AWS_SECRET_ACCESS_KEY` | Environment | Your AWS secret key (sensitive) |
    | `TF_VAR_db_password` | Terraform | Database password (sensitive) |
    | `TF_VAR_region` | Terraform | AWS region (e.g., "eu-west-1") |
    | `TF_VAR_ecr_repository_url` | Terraform | ECR repository URL for container images (e.g., `288761743924.dkr.ecr.eu-west-1.amazonaws.com/lampstack`) |

3.  **Configure Execution Settings:**

      * Set execution mode to "Remote."
      * Enable "Auto apply" for automatic deployments (optional, but used here).
      * Configure VCS triggers to run on pull requests (recommended for review).

4.  **Standard Workflow:**

      * Push changes to your connected repository (`git push`).
      * Terraform Cloud detects VCS changes.
      * An automatic `terraform plan` executes.
      * If auto-apply is enabled, changes are deployed to AWS; otherwise, manual approval is required.

5.  **Image Update Workflow:**

      * Update your application's Docker image and push the new version to ECR.
      * Update the `container_image` variable (or the `image` in the task definition) in your Terraform configuration to reference the new image tag.
      * Terraform Cloud triggers a new deployment of the ECS task definition.

#### 4.3.2 Local Deployment

For local development and testing, you can deploy directly from your machine.

1.  **Clone the Repository:**

    ```bash
    git clone -b ecs-feature https://github.com/guderian120/lamp_stack_infranstructure
    cd lamp_stack_infranstructure
    ```

2.  **Configure Terraform Backend:**
    Ensure your `backend.tf` is configured for Terraform Cloud (or adjust if you prefer local state management):

    ```hcl
    terraform {
      backend "remote" {
        organization = "your-org-name" # Replace with your Terraform Cloud organization
        
        workspaces {
          name = "prod-ecs-lamp-stack" # Replace with your workspace name
        }
      }
    }
    ```

3.  **Build and Push Docker Image:**
    First, clone the application code and build/push the Docker image to ECR.

    ```bash
    cd .. # Go up from the infra folder
    git clone https://github.com/guderian120/lamp_stack_application # Clone the PHP code
    cd lamp_stack_application
    docker build -t lamp-stack ./docker
    aws ecr get-login-password | docker login --username AWS --password-stdin YOUR_ECR_URL # Replace YOUR_ECR_URL with your actual ECR URL
    docker tag lamp-stack:latest YOUR_ECR_URL/lamp-stack:latest
    docker push YOUR_ECR_URL/lamp-stack:latest
    ```

    (Then return to the infrastructure directory: `cd ../lamp_stack_infranstructure`)

4.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

5.  **Configure Local Variables:**
    Create a `terraform.tfvars` file in your `lamp_stack_infranstructure` directory with your configuration:

    ```hcl
    environment = "prod"
    region = "eu-west-1"
    db_password = "your-secure-password" # Ensure this matches your Terraform Cloud sensitive variable
    ecr_repository_url = "your-account-id.dkr.ecr.region.amazonaws.com/your-repo" # Ensure this matches your Terraform Cloud variable
    ```

6.  **Apply Changes:**

      * Review proposed changes:
        ```bash
        terraform plan
        ```
      * Apply the configuration:
        ```bash
        terraform apply
        ```
        Confirm by typing `yes` when prompted.

This process will deploy resources in both `eu-west-1` (Primary) and `eu-central-1` (DR). The DR ECS service `desired_count` will be `0` by default.

### 4.4 Key Outputs

Upon successful deployment, Terraform will output key endpoints:

  * **Primary Website URL:** `http://ecsstack-alb-1662418084.eu-west-1.elb.amazonaws.com`
  * **Primary Database Endpoint:** `prod-ecs-db.cda62s0o6etz.eu-west-1.rds.amazonaws.com:3306`
  * (Other outputs related to DR endpoints will also be available for failover purposes, such as `alb_dns_name` if configured as an output in your Terraform).

## 5\. Disaster Recovery Procedures

This section outlines the process for failing over to the DR region and subsequently failing back to the primary region.

### 5.1 Failover Process

In the event of a primary region outage, follow these steps to activate the DR environment:

1.  **Stop Primary Application (if possible):** If the primary region is partially available, attempt to gracefully stop or scale down the ECS service to prevent data corruption.
2.  **Promote DR RDS Read Replica:**
      * Navigate to the Amazon RDS console in `eu-central-1`.
      * Select the `dr-ecs-db` read replica.
      * Choose "Actions" -\> "Promote". Confirm the promotion. This will convert it into a standalone writable database instance.
      * **Note:** After promotion, the DR database will have a new endpoint. Update the ECS task definition in the next step with this new endpoint if it changes.
3.  **Update DR ECS Task Definition (if necessary):** If the promoted DR database's endpoint changes, update the `DB_HOST` environment variable in the `dr_ecsstack-task` definition to point to the new DR database endpoint.
      * This may involve creating a new revision of the task definition.
4.  **Scale Up DR ECS Service:**
      * Go to the Amazon ECS console in `eu-central-1`.
      * Select the `dr_ecsstack-cluster` and then the `dr_ecsstack-service`.
      * Click "Update" and change the "Desired tasks" count from `0` to your desired operational count (e.g., `2`). This will launch new Fargate tasks.
5.  **DNS Failover:**
      * Update your public DNS records (e.g., in Amazon Route 53) to point your primary application domain name to the DNS name of the DR Application Load Balancer (`ecsstack-alb-1121063250.eu-central-1.elb.amazonaws.com`).
      * Monitor DNS propagation.
6.  **Verify Application Availability:**
      * Test the application thoroughly via the new DR URL.

### 5.2 Failback Process

Returning operations to the primary region after a disaster:

1.  **Ensure Primary Region Recovery:** Verify that the primary `eu-west-1` region is fully operational and stable.
2.  **Snapshot DR Database:** Take a final snapshot of the promoted DR database in `eu-central-1` to capture any data changes made during the DR period.
3.  **Create New Primary Database (in eu-west-1):**
      * Restore the snapshot from the DR database into a *new* RDS instance in `eu-west-1`. This will become the new primary database.
      * Alternatively, if you prefer to use the *original* primary DB instance, you would need to restore *it* from the DR snapshot, potentially requiring a new endpoint.
4.  **Configure Replication:** Set up a new read replica from the newly established primary database in `eu-west-1` back to the `eu-central-1` DR region.
5.  **Update Primary ECS Task Definition:** Update the `DB_HOST` environment variable in the primary `ecsstack-task` definition to point to the new primary database endpoint.
6.  **Scale Up Primary ECS Service:** Scale up the primary ECS service's `desired_count` to its operational level.
7.  **Scale Down DR ECS Service:** Once the primary is verified, scale down the DR ECS service `desired_count` to `0`.
8.  **DNS Failback:** Update your public DNS records back to the original primary ALB DNS name (`ecsstack-alb-1662418084.eu-west-1.elb.amazonaws.com`).
9.  **Verify Application Availability:** Test the application thoroughly via the original primary URL.
10. **Cleanup (Optional):** Once confident, you can delete the temporary resources created in the DR region during failover (e.g., the promoted DR database if a new replica was created).

### 5.3 RTO/RPO Considerations

  * **RPO (Recovery Point Objective):** Determined by the latency of RDS cross-region replication. For asynchronous replication, it will be in seconds to minutes, depending on the workload.
  * **RTO (Recovery Time Objective):** Dependent on DNS propagation time (minutes to hours) and the time taken to scale up ECS services and promote the database (typically 5-15 minutes combined for infrastructure activation).

## 6\. Monitoring and Logging

Effective monitoring and logging are crucial for operational visibility and quick issue resolution.

### 6.1 Application Logging

  * **CloudWatch Logs:** All ECS Fargate tasks are configured to send their standard output and error streams to Amazon CloudWatch Logs, in the log group `/ecs/ecsstack` in their respective regions. This centralizes container logs.
  * **Access Logs:** ALB access logs (though not enabled by default in the state file) can be configured to capture detailed information about requests sent to the load balancer, which can be stored in S3.

### 6.2 Infrastructure Monitoring

  * **Amazon CloudWatch:** Automatically collects metrics for AWS services such as ECS, RDS, and ALB.
      * **ECS Metrics:** CPU utilization, memory utilization, desired task count, running task count, etc.
      * **RDS Metrics:** CPU utilization, database connections, free storage, read/write IOPS, replication lag (for the DR replica).
      * **ALB Metrics:** Request count, latency, HTTP error codes, healthy/unhealthy host counts.
  * **CloudWatch Alarms:** Alarms can be configured on these metrics to trigger notifications (e.g., via SNS) for critical events (e.g., high CPU, low disk space, high replication lag, unhealthy targets).

## 7\. Security Considerations

Security is paramount in any cloud deployment.

### 7.1 Network Security

  * **VPC Isolation:** Resources are deployed within private VPCs, logically isolated from other AWS customers.
  * **Subnet Segmentation:** Public and private subnets enforce controlled access, with application and database tiers residing in private subnets.
  * **Security Groups:** Act as stateful firewalls at the instance level, allowing precise control over ingress and egress traffic.
      * ALB receives traffic from the internet.
      * ECS tasks receive traffic only from the ALB.
      * RDS database receives traffic only from ECS tasks.
  * **NACLs (Network Access Control Lists):** (Not explicitly detailed in state, but can be used for stateless subnet-level filtering).

### 7.2 IAM Roles and Permissions

  * **ECS Task Execution Role:** `ecsstack-ecs-task-execution-role` (ARN: `arn:aws:iam::288761743924:role/ecsstack-ecs-task-execution-role`). This role grants ECS permission to pull images from ECR and publish logs to CloudWatch.
  * **ECS Task Role:** (Not explicitly defined in the provided task definition, but typically used for application-specific permissions, e.g., accessing S3, Secrets Manager).
  * **RDS Monitoring Role:** `rds_monitoring_role` (implied from RDS config).
  * **Principle of Least Privilege:** All IAM roles and policies should adhere to the principle of least privilege, granting only the necessary permissions.

### 7.3 Data Encryption

  * **RDS Encryption:** The RDS database instances (both primary and DR) are configured with storage encryption enabled (`storage_encrypted: true`), protecting data at rest using AWS KMS.
  * **Data in Transit:** Sensitive data in transit between the application and database should be encrypted using SSL/TLS. (This needs to be configured at the application and database client level, not directly visible in Terraform state).

## 8\. Maintenance and Operations

### 8.1 Scaling Operations

  * **Service Scaling**: Adjust the `desired_count` of your ECS service directly or configure application auto-scaling policies based on metrics like CPU utilization or request count.
  * **Task Resources**: Modify CPU and memory limits within the ECS task definition to optimize performance and cost.

### 8.2 Updates

1.  **Container Updates**:

      * Build and push the new Docker image version to the ECR repository.
      * Update the `container_image` tag within the ECS task definition (or the relevant Terraform variable).
      * Terraform Cloud CI/CD will automatically trigger a new deployment of the ECS service, performing a rolling update to the new image.

2.  **Configuration Changes**:

      * Modify any infrastructure parameters in your Terraform configuration files (e.g., VPC CIDR, security group rules, RDS instance type).
      * Apply changes through the Terraform Cloud CI/CD workflow (push to connected repository).

### 8.3 Backup and Recovery

  * **Database Backups**: Amazon RDS automatically performs backups with configurable retention periods. These automated backups are distinct from the cross-region read replica used for DR.
  * **State Management**: Terraform Cloud manages the remote state, providing automatic state versioning and locking to prevent conflicts.

### 8.4 Destruction

To remove all provisioned resources:

1.  In your Terraform Cloud workspace, navigate to "Settings" -\> "Destruction & Deletion."
2.  Queue a destroy plan and confirm the destruction. **Caution: This will permanently delete all AWS resources managed by this Terraform configuration.**

## 9\. Best Practices & Troubleshooting

### 9.1 Best Practices

  * **Security**:
      * Always use Terraform Cloud's sensitive variable handling for credentials and passwords.
      * Consider implementing Sentinel policies in Terraform Cloud for advanced governance and compliance checks.
      * Enable VPC flow logs for comprehensive network traffic monitoring and anomaly detection.
  * **CI/CD Optimization**:
      * Utilize separate Terraform Cloud workspaces for different environments (e.g., `dev`, `staging`, `prod`) to isolate deployments.
      * Integrate image scanning (e.g., AWS ECR image scanning) into your CI/CD pipeline to identify vulnerabilities before deployment.
      * Employ pre-commit hooks to validate Terraform code formatting and syntax locally before pushing to the repository.
  * **Cost Management**:
      * Right-size Fargate task CPU and memory resources to match your application's actual needs to avoid over-provisioning.
      * Implement auto-scaling policies for ECS services to dynamically adjust capacity based on demand, scaling in during low traffic.
      * Regularly review and clean up unused or orphaned AWS resources to prevent unnecessary costs.

### 9.2 Troubleshooting

| Issue | Solution |
|-------|----------|
| ECS tasks not starting | Check CloudWatch logs for the ECS tasks for application errors. Review the ECS service events for deployment failures. Verify IAM roles and security group configurations. |
| ALB health check failures | Ensure the container's health check endpoint (e.g., `/`) is accessible and returns a 200 OK status. Verify that the ECS task's security group allows inbound traffic from the ALB's security group on the correct port. |
| Terraform Errors (e.g., `invalid configuration`) | Review the specific error message. Check your `main.tf` and module configurations for syntax errors or incorrect resource arguments. Ensure all required variables are set. |
| Terraform Cloud runs not triggering | Verify the VCS connection in your Terraform Cloud workspace settings. Check for any branch filters or VCS triggers that might be preventing runs. |
| AWS Authentication errors | Double-check that `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are correctly configured as environment variables (and marked sensitive) in your Terraform Cloud workspace. Ensure the IAM user has the necessary permissions. |

## 10\. Support

### 10.1 Live Deployment

The application is currently deployed and accessible at:
[](http://ecsstack-alb-860145636.eu-west-1.elb.amazonaws.com/index.php)

### 10.2 Further Assistance

For additional assistance or issues:

  * [Terraform Cloud Documentation](https://www.terraform.io/docs/cloud)
  * [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/best-practices.html)
  * Repository Issues: [https://github.com/guderian120/lamp\_stack\_infranstructure/issues](https://github.com/guderian120/lamp_stack_infranstructure/issues)

For production deployments, consider HashiCorp's paid support options for Terraform Cloud.