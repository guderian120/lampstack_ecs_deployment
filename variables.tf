variable "db_password" {
  description = "Master password (should be passed via environment variables)"
  type        = string
  sensitive   = true
}

variable "ecr_repository_url" {
  description = "ecr repository url"
  type        = string
}

variable "primary_region" {
  description = "primary region"

}


variable "dr_region" {
  description = "region for DR"
}
variable "account_id" {
  description = "account id"
}

variable "kms_key_arn" {
  description = "arn of kms key"
}
variable "kms_replica_arn" {
  description = "arn for key replica"
}