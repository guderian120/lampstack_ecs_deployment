variable "sns_topic_arn" {
  description = "arn of sns topic"
}

variable "alb_arn" {
  description = "arn of alb"
}

variable "DR_ALB_LISTENER_ARN" {
  description = "arn of dr listener"

}

variable "target_group_arn" {
  description = "arn of target group" 
  
}
variable "service_name" {
  description = "name of the ecs service"
}

variable "cluster_name" {
  description = "name of the ecs cluster"
  
}