output "ecs_service" {
    value = aws_ecs_service.service.name
    }


output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
  
}
  
