output "this_kms_key_id" {
  description = "KMS key to encrypt environment variables in SSM"
  value       = aws_kms_key.this.key_id
}

output "this_kms_key_arn" {
  description = "KMS key to encrypt environment variables in SSM"
  value       = aws_kms_key.this.arn
}
