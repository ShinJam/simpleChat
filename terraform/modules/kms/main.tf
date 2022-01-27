resource "aws_kms_key" "this" {
  description         = "KMS custom key for parameter store"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}-parameter-store-encryption"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_grant" "this" {
  name              = "staging-grant"
  key_id            = aws_kms_key.this.key_id
  grantee_principal = var.jenkins_role_arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey"]
}
