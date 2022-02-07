// https://github.com/terraform-aws-modules/terraform-aws-s3-bucket
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.13.0"

  bucket_prefix = "${var.bucket_prefix}-"
  acl           =  var.acl
  force_destroy = true

  attach_policy = true
  policy        = var.policy

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  versioning = {
    enabled = true
  }

  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  cors_rule = [{
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
    }
  ]

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  # S3 Bucket Ownership Controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  tags = var.tags
}

# vue-bucket-policy
data "aws_iam_policy_document" "vue_bucket_policy" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}",
      "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}/*",
    ]
  }
}
