# variables.tf
variable "name_prefix" {
  type        = string
  description = "Prefix for all resources"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the DB subnet group"
}

variable "kms_key_arn" {
  description = "arn of kms key"
}
variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for the DB instance"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
}

variable "engine" {
  type        = string
  default     = "mysql"
  description = "Database engine type"
}

variable "engine_version" {
  type        = string
  description = "Database engine version"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Database instance class"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
}

variable "username" {
  type        = string
  description = "Master username"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Master password"
}

variable "parameter_group_name" {
  type        = string
  default     = "default.mysql5.7"
  description = "Parameter group name"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip final snapshot when destroying"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Backup retention period in days"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}

# New variables for replica configuration
variable "is_replica" {
  type        = bool
  default     = false
  description = "Whether this is a read replica"
}

variable "replicate_source_db" {
  type        = string
  default     = null
  description = "ARN of the source DB for replication"
}

variable "backup_window" {
  type        = string
  default     = "03:00-04:00"
  description = "Preferred backup window"
}

variable "maintenance_window" {
  type        = string
  default     = "sun:04:00-sun:05:00"
  description = "Preferred maintenance window"
}

variable "multi_az" {
  description = "multi availability zone support"
}
variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Enable storage encryption"
}