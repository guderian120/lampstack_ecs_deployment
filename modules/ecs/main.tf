# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "${var.app_name}-container"
    image     = var.ecr_repository_url
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.host_port
    }]
    
    # Add environment variables, secrets, etc. as needed
    environment = [
      {
        name  = "DB_HOST"
        value = var.db_host
      },
      {
        name  = "DB_NAME"
        value = var.db_name
      },
      {
        name  = "DB_USER"
        value = var.db_user
      },
      {
        name  = "DB_PASS"
        value = var.db_password
      }

    ]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.security_group.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.app_name}-container"
    container_port   = var.container_port
  }

  depends_on = [var.alb_listener]
}