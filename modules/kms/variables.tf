variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}


variable "region" {
  description = "region of kms key"
}

variable "account_id" {
  description = "account id "
}

variable "dr_region" {
  default = "eu-central-1"
}