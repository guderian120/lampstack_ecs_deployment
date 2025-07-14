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



