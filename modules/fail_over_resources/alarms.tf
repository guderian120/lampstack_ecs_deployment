# modules/primary_region/alarms.tf
# ALB Unhealthy Hosts
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {

  alarm_name          = "alb-unhealthy-hosts-eu-west-1a"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  dimensions = {
    TargetGroup      = var.target_group_arn
    AvailabilityZone = "eu-west-1a"
    LoadBalancer     = var.alb_arn
  }
  period            = 60
  threshold         = 0
  statistic         = "Sum"
  alarm_description = "Triggers if ALB has unhealthy hosts in eu-west-1a"
  alarm_actions     = [var.sns_topic_arn]
}

# ALB 5xx Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  dimensions = {
    LoadBalancer = var.alb_arn
  }
  period            = 60
  threshold         = 10 # Alert if >10 5xx errors in 1 minute
  statistic         = "Sum"
  alarm_description = "Triggers if ALB generates 5xx errors"
  alarm_actions     = [var.sns_topic_arn]
}


# ECS 

# ECS Service CPU/Memory Throttling (Optional)
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_throttling" {
  alarm_name          = "ecs-cpu-throttling"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
  period            = 60
  threshold         = 90 # Alert if CPU >90% for 3 minutes
  statistic         = "Average"
  alarm_description = "Triggers if ECS tasks are CPU-throttled"
  alarm_actions     = [var.sns_topic_arn]
}

