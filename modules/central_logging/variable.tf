variable "logs_bucket_name" {
  description = "Name of the S3 bucket for storing logs"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs in S3"
  type        = number
  default     = 365
}

variable "cloudwatch_log_retention" {
  description = "Retention period for CloudWatch logs (in days)"
  type        = number
  default     = 30
}

variable "alb_account_id" {
  description = "AWS account ID that owns the ALB (use 033677994240 for us-east-1)"
  type        = string
  default     = "033677994240" # Default is us-east-1 ALB account
}

variable "ec2_instance_role_name" {
  description = "Name of the IAM role attached to EC2 instances"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "lamp-stack"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_s3_export" {
  description = "Whether to enable automatic export of CloudWatch logs to S3"
  type        = bool
  default     = true
}