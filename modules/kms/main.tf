resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption in ${var.region}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy.json

  tags = merge(
    var.tags,
    {
      Name = "rds-encryption-key-${var.region}"
    }
  )
}

resource "aws_kms_alias" "rds" {
  name          = "alias/rds-encryption-key-${var.region}"
  target_key_id = aws_kms_key.rds.key_id
}

data "aws_iam_policy_document" "kms_policy" {
  # Root account full access - MUST include policy management
  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:user/DevOps_user"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Explicit policy management permissions
   



  # RDS service permissions
  statement {
    sid    = "AllowRDSServiceUse"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  
}