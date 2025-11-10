##################################################################################
# s3 Module #
##################################################################################

// Module creates KMS and its related resources
module "kms" {
  source  = "sourcefuse/arc-kms/aws"
  version = "1.0.11"
  count   = var.s3_kms_details.s3_bucket_encryption_type == "SSE-KMS" && var.s3_kms_details.kms_key_arn == null ? 1 : 0

  alias                   = "${local.environment}-s3-${var.logging_bucket}"
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 Service"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

data "aws_s3_bucket" "origin" {
  for_each = {
    for index, origin in var.origins : origin.origin_id => origin
    if origin.create_bucket == false && origin.origin_type == "s3"
  }
  bucket = each.value.bucket_name
}

module "s3_bucket" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.5"

  for_each = {
    for index, origin in var.origins : origin.origin_id => origin
    if origin.create_bucket == true && origin.origin_type == "s3"
  }

  name = each.value.bucket_name
  acl  = "private"

  tags = var.tags
}

module "s3_bucket_logs" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.5"

  count = var.enable_logging ? 1 : 0

  name = "${var.logging_bucket}-logging"
  acl  = "private"

  tags = var.tags
}
