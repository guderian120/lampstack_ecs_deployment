output "key_arn" {
  value = aws_kms_key.rds.arn
}

output "key_id" {
  value = aws_kms_key.rds.key_id
}

output "alias_arn" {
  value = aws_kms_alias.rds.arn
}