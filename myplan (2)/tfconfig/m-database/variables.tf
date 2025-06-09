variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "lamp-db"
}

variable "vpc_id" {
  description = "VPC ID where the database will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the database"
  type        = list(string)
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "lampdb"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Master password (should be passed via environment variables)"
  type        = string
  sensitive   = true
}

variable "parameter_group_name" {
  description = "DB parameter group name"
  type        = string
  default     = "default.mysql8.0"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying DB"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}