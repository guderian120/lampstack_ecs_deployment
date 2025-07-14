output "primary_vpc_id" {
  value = module.primary_vpc.vpc_id
}

output "primary_public_subnet_ids" {
  value = module.primary_vpc.public_subnet_ids
}

output "primary_private_subnet_ids" {
  value = module.primary_vpc.private_subnet_ids
}

output "primary_web_security_group_id" {
  value = module.primary_security_groups.web_security_group_id
}

output "primary_database_security_group_id" {
  value = module.primary_security_groups.database_security_group_id
}

output "primary_db_endpoint" {
  value     = module.primary_database.db_instance_endpoint
  sensitive = true
}

output "primary_website_url" {
  value = "http://${module.primary_ecs_alb.alb_dns_name}"
}



# ╷
# │ Error: creating RDS DB Subnet Group (dr-ecs-db-subnet-group): operation error RDS: CreateDBSubnetGroup, https response error StatusCode: 400, RequestID: 24b50b5b-57aa-4a9c-b8aa-45212880b9cd, api error InvalidParameterValue: Some input subnets in :[subnet-002dbe029178cb8da] are invalid.
# │ 
# │   with module.dr_database.aws_db_subnet_group.this,
# │   on modules/database/main.tf line 1, in resource "aws_db_subnet_group" "this":
# │    1: resource "aws_db_subnet_group" "this" {
# │ 
# ╵
# ╷
# │ Error: creating RDS DB Subnet Group (prod-ecs-db-subnet-group): operation error RDS: CreateDBSubnetGroup, https response error StatusCode: 400, RequestID: ef26292e-d69b-4ad8-94b5-7100b47ce3af, api error InvalidParameterValue: Some input subnets in :[subnet-0efd7d675f49b345c, subnet-0e0f35a571d901ebd] are invalid.
# │ 
# │   with module.primary_database.aws_db_subnet_group.this,
# │   on modules/database/main.tf line 1, in resource "aws_db_subnet_group" "this":
# │    1: resource "aws_db_subnet_group" "this" {
# │ 
# ╵
# ╷
# │ Error: creating ELBv2 application Load Balancer (ecsstack-alb): operation error Elastic Load Balancing v2: CreateLoadBalancer, https response error StatusCode: 400, RequestID: 93aab1fb-de76-404c-b5e4-d7aadcdb0d89, api error ValidationError: At least two subnets in two different Availability Zones must be specified
# │ 
# │   with module.dr_ecs_alb.aws_lb.ecs,
# │   on modules/ecs_alb/main.tf line 2, in resource "aws_lb" "ecs":
# │    2: resource "aws_lb" "ecs" {
# │ 
# ╵
# ╷
# │ Error: creating IAM Role (ecsstack-ecs-task-execution-role): operation error IAM: CreateRole, https response error StatusCode: 409, RequestID: c41e2594-292e-477d-9c76-f2f6825366f1, EntityAlreadyExists: Role with name ecsstack-ecs-task-execution-role already exists.
# │ 
# │   with module.dr_ecs_alb.aws_iam_role.ecs_task_execution_role,
# │   on modules/ecs_alb/main.tf line 39, in resource "aws_iam_role" "ecs_task_execution_role":
# │   39: resource "aws_iam_role" "ecs_task_execution_role" {
# │ 


# │ Error: waiting for ELBv2 Load Balancer (arn:aws:elasticloadbalancing:eu-west-1:288761743924:loadbalancer/app/ecsstack-alb/d2fbd9b7deb5743d) create: timeout while waiting for state to become 'active' (timeout: 10m0s)
# │ 
# │   with module.primary_ecs_alb.aws_lb.ecs,
# │   on modules/ecs_alb/main.tf line 2, in resource "aws_lb" "ecs":
# │    2: resource "aws_lb" "ecs" {
# │ 
# ╵
# ╷
# │ Error: waiting for ELBv2 Load Balancer (arn:aws:elasticloadbalancing:eu-central-1:288761743924:loadbalancer/app/ecsstack-alb/cfa93725c3bc3330) create: timeout while waiting for state to become 'active' (timeout: 10m0s)
# │ 
# │   with module.dr_ecs_alb.aws_lb.ecs,
# │   on modules/ecs_alb/main.tf line 2, in resource "aws_lb" "ecs":
# │    2: resource "aws_lb" "ecs" {
# │ 
# ╵
# ╷
# │ Error: creating IAM Role (ecsstack-ecs-task-execution-role): operation error IAM: CreateRole, https response error StatusCode: 409, RequestID: bb6a9874-e8f0-4dd8-a13f-c93b308ec2d9, EntityAlreadyExists: Role with name ecsstack-ecs-task-execution-role already exists.
# │ 
# │   with module.dr_ecs_alb.aws_iam_role.ecs_task_execution_role,
# │   on modules/ecs_alb/main.tf line 39, in resource "aws_iam_role" "ecs_task_execution_role":
# │   39: resource "aws_iam_role" "ecs_task_execution_role" {
# │ 
# ╵
# ╷
# │ Error: creating KMS Key: operation error KMS: CreateKey, https response error StatusCode: 400, RequestID: 6cfdb1a7-b78d-4e7a-b0b3-485352ed9026, MalformedPolicyDocumentException: The new key policy will not allow you to update the key policy in the future.
# │ 
# │   with module.primary_kms.aws_kms_key.rds,
# │   on modules/kms/main.tf line 1, in resource "aws_kms_key" "rds":
# │    1: resource "aws_kms_key" "rds" {
# │ 
# ╵
# ╷
# │ Error: waiting for EC2 NAT Gateway (nat-0d33e1d81081d4c9a) create: timeout while waiting for state to become 'available' (last state: 'pending', timeout: 10m0s)
# │ 
# │   with module.primary_vpc.aws_nat_gateway.this[0],
# │   on modules/vpc/main.tf line 102, in resource "aws_nat_gateway" "this":
# │  102: resource "aws_nat_gateway" "this" {
# │ 
# ╵
# ╷
# │ Error: waiting for EC2 NAT Gateway (nat-011cda08b1851801e) create: timeout while waiting for state to become 'available' (last state: 'pending', timeout: 10m0s)
# │ 
# │   with module.dr_vpc.aws_nat_gateway.this[0],
# │   on modules/vpc/main.tf line 102, in resource "aws_nat_gateway" "this":
# │  102: resource "aws_nat_gateway" "this" {
# │ 