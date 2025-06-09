variable "db_password" {
  description = "Master password (should be passed via environment variables)"
  type        = string
  sensitive   = true
}