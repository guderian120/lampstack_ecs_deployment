output "ecs_security_group" {
  value = aws_security_group.ecs
}
output "alb_security_group" {
  value = aws_security_group.alb
}
output "target_group_arn" {
  value = aws_lb_target_group.ecs.arn
}

output "alb_listener" {
  value = aws_lb_listener.ecs
}

output "ecs_task_execution_role" {
  value = aws_iam_role.ecs_task_execution_role
}


output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.ecs.dns_name
}

output "ecs_log_group" {
  value = aws_cloudwatch_log_group.ecs.name
}