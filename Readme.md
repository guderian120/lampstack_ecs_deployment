

## 📝 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Repository Structure](#repository-structure)
5. [Deployment Guide](#deployment-guide)

   * 5.1 [Bootstrap Pilot Light (`primary` stack)](#bootstrap-primary-stack)
   * 5.2 [Synchronizing Database & Assets](#sync-db-assets)
   * 5.3 [Failover Procedure (`DR` stack)](#failover-dr-stack)
6. [Configuration](#configuration)

   * 6.1 [ECS Service & Task Definitions](#ecs-service-task-definitions)
   * 6.2 [Networking & Security](#networking-security)
   * 6.3 [IAM Roles & Policies](#iam-roles-policies)
   * 6.4 [Secrets & Environment Variables](#secrets-env-vars)
7. [Operational Considerations](#operational-considerations)

   * 7.1 [Scaling & High Availability](#scaling-ha)
   * 7.2 [Monitoring & Alerts](#monitoring-alerts)
   * 7.3 [Failback Procedure](#failback)
8. [Cost Management](#cost-management)
9. [Development & Testing Workflow](#testing-workflow)
10. [Cleanup & Teardown](#cleanup)
11. [License & Contributing](#license)

---

## 1. Overview <a name="overview"></a>

This repository contains infrastructure-as-code and deployment scripts to build a high-availability, pilot‑light disaster recovery (DR) LAMP stack using AWS ECS, RDS, S3, IAM, and other services. In normal operations, only minimal core services (web, DB replica, static assets) are running in a secondary “pilot” region. In a DR event, the full application stack is spun up and traffic is failed over with minimal downtime.

---

## 2. Architecture <a name="architecture"></a>

* **Primary Region**: Full ECS cluster running web & backend containers. Production RDS instance. S3 for static content.
* **Secondary (Pilot-Light) Region**: Minimal ECS (scheduled task), RDS read replica, passive S3 bucket. CloudWatch monitors replication lag and health.
* **Failover Process**: Promote secondary DB, deploy full ECS stack, update Route 53 record to point to DR region ALB.

Diagram (example required):

```
[Client] → Route53 → ALB-primary → ECS-web → RDS-primary
                    ↘ Pilot ECS (warm)
        DB-replication → RDS-replica
S3 replication → S3-secondary
```

---

## 3. Prerequisites <a name="prerequisites"></a>

* AWS CLI + credentials configured with appropriate permissions
* Terraform or CloudFormation (depending on IaC files)
* Docker + ECR access
* Route 53 zone configured for your domain
* Runtime secret store (Secrets Manager or Parameter Store)
* (Optional) VPN or Bastion for private networking

---

## 4. Repository Structure <a name="repository-structure"></a>

```
./
├── infrastructure/         # Terraform or CloudFormation definitions
│   ├── primary/            # Resources for primary region
│   └── pilot-light/        # Pilot‑light setup for secondary region
├── ecs/                    # Task definitions & ECS service manifests
├── db/                     # RDS configuration (primary + replica)
├── s3/                     # Bucket config and replication rules
├── scripts/                # Deployment & helper scripts
│   ├── bootstrap.sh        # Deploy pilot stack
│   ├── sync.sh             # DB & asset sync script
│   └── failover.sh         # Promote and switch traffic
└── README.md
```

---

## 5. Deployment Guide <a name="deployment-guide"></a>

### 5.1 Bootstrap Pilot Light (`primary` stack) <a name="bootstrap-primary-stack"></a>

1. Configure AWS credentials and region variables.
2. Deploy RDS read replica in secondary region.
3. Create ECS cluster with minimal web/task definitions (e.g. single small Fargate).
4. Configure cross-region S3 replication for static content.

Usage:

```bash
cd infrastructure/pilot-light
terraform init && terraform apply
bash ../../scripts/bootstrap.sh
```

---

### 5.2 Synchronizing Database & Assets <a name="sync-db-assets"></a>

Run periodic sync via CloudWatch Event or cron:

```bash
bash scripts/sync.sh \
  --source-db-endpoint PRIMARY_DB_ENDPOINT \
  --target-replica-endpoint REPLICA_DB_ENDPOINT
```

* Dumps and imports database.
* Copies new static files to secondary S3 bucket.

---

### 5.3 Failover Procedure (`DR` stack) <a name="failover-dr-stack"></a>

Initiate on DR event:

```bash
cd infrastructure/dr-stack
terraform init && terraform apply
bash ../../scripts/failover.sh \
  --replica-endpoint REPLICA_DB_ENDPOINT \
  --route53-zone ZONE_ID \
  --record-name app.example.com
```

* Promotes RDS replica to standalone,
* Brings up ECS cluster & services in DR region,
* Updates DNS to route to DR ALB.

---

## 6. Configuration <a name="configuration"></a>

### 6.1 ECS Service & Task Definitions <a name="ecs-service-task-definitions"></a>

* Container specs: Apache/PHP, Nginx,
* CPU/memory allocations,
* Health-check endpoint `/health`.

### 6.2 Networking & Security <a name="networking-security"></a>

* VPC, subnets, security groups per region,
* ALB with HTTPS, TLS cert via ACM,
* Load balancer health checks.

### 6.3 IAM Roles & Policies <a name="iam-roles-policies"></a>

* ECS Task Role for S3 & Secrets Manager,
* Lambda/CloudWatch IAM roles for sync,
* Route53 update policy.

### 6.4 Secrets & Environment Variables <a name="secrets-env-vars"></a>

* Store DB credentials in Secrets Manager,
* ENV injected via ECS TaskDefinition / Parameter Store.

---

## 7. Operational Considerations <a name="operational-considerations"></a>

### 7.1 Scaling & High Availability <a name="scaling-ha"></a>

* Pilot region minimal scale (1 task + DB replica),
* Primary region autoscaling enabled via CPU/memory metrics.

### 7.2 Monitoring & Alerts <a name="monitoring-alerts"></a>

* CloudWatch monitors RDS lag, ECS task health,
* SNS/Slack notifications on threshold breaches.

### 7.3 Failback Procedure <a name="failback"></a>

* After recovery, re-seed primary from DR DB,
* Reconfigure ECS and DNS back to primary,
* Tear down DR ECS stack optionally.

---

## 8. Cost Management <a name="cost-management"></a>

* Pilot region uses minimal infrastructure to reduce costs,
* RDS replica billed similarly to primary; consider smaller class,
* S3 cross-region replication cost and data transfer.

---

## 9. Development & Testing Workflow <a name="testing-workflow"></a>

* Use staging AWS accounts/regions,
* Local tests via Docker compose,
* CI pipeline to validate infrastructure (e.g., terraform fmt, validate).

---

## 10. Cleanup & Teardown <a name="cleanup"></a>

To dismantle DR setup:

```bash
cd infrastructure/dr-stack
terraform destroy
```

Then rollback DNS and optionally remove pilot region resources.

---

## 11. License & Contributing <a name="license"></a>

* License: (add LICENSE file / MIT, Apache 2.0, etc.)
* Contributions: fork → commit → PR.
* Please run `terraform fmt`, provide regression tests for scripts, and validate ECS health checks.

---