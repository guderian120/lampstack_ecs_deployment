variable "db_password" {
  description = "Master password (should be passed via environment variables)"
  type        = string
  sensitive   = true
}

variable "ecr_repository_url"{
  description = "ecr repository url"
  type = string
}