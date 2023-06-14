##################################################################################
# s3 Module #
##################################################################################

// Module creates KMS and its related resources
module "kms" {
  count = var.s3_kms_details.s3_bucket_encryption_type == "SSE-KMS" && var.s3_kms_details.kms_key_arn == null ? 1 : 0

  source                  = "./modules/kms"
  environment             = local.environment
  alias                   = "${local.environment}/s3/${var.logging_bucket}"
  kms_key_administrators  = var.s3_kms_details.kms_key_administrators
  kms_key_users           = var.s3_kms_details.kms_key_users
  deletion_window_in_days = 7
  aws_services            = ["s3.amazonaws.com", "cloudfront.amazonaws.com"]
  tags                    = var.tags
}

data "aws_s3_bucket" "origin" {
  for_each = {
    for index, origin in var.origins : origin.origin_id => origin
    if origin.create_bucket == false && origin.origin_type == "s3"
  }
  bucket = each.value.bucket_name
}

module "s3_bucket" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.1.2"

  for_each = {
    for index, origin in var.origins : origin.origin_id => origin
    if origin.create_bucket == true && origin.origin_type == "s3"
  }

  //count = var.create_bucket ? 1 : 0

  bucket_name = each.value.bucket_name
  environment = local.environment
  namespace   = var.namespace

  enabled            = true
  acl                = "private"
  versioning_enabled = true
  bucket_key_enabled = var.s3_kms_details.s3_bucket_encryption_type == "SSE-KMS" ? true : false
  kms_master_key_arn = var.s3_kms_details.s3_bucket_encryption_type == "SSE-S3" ? "" : (var.s3_kms_details.kms_key_arn == null ? module.kms[0].key_arn : var.s3_kms_details.kms_key_arn)
  sse_algorithm      = var.s3_kms_details.s3_bucket_encryption_type == "SSE-S3" ? "AES256" : "aws:kms"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:root"
        },
        Action = [
          "s3:GetObjectAttributes",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        Resource = "arn:${data.aws_partition.this.partition}:s3:::${var.namespace}-${terraform.workspace}-deployment/*"
      }
    ]
  })

  privileged_principal_actions = [
    "s3:GetObject",
    "s3:ListBucket",
    "s3:GetBucketLocation"
  ]
  cors_configuration = var.cors_configuration
  tags               = var.tags
}

module "s3_bucket_logs" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.1.2"

  count = var.enable_logging ? 1 : 0

  bucket_name = "${var.logging_bucket}-logging"
  environment = local.environment
  namespace   = var.namespace

  acl                = "log-delivery-write"
  versioning_enabled = false
  bucket_key_enabled = var.s3_kms_details.s3_bucket_encryption_type == "SSE-KMS" ? true : false
  kms_master_key_arn = var.s3_kms_details.s3_bucket_encryption_type == "SSE-S3" ? "" : (var.s3_kms_details.kms_key_arn == null ? module.kms[0].key_arn : var.s3_kms_details.kms_key_arn)
  sse_algorithm      = var.s3_kms_details.s3_bucket_encryption_type == "SSE-S3" ? "AES256" : "aws:kms"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:root"
        },
        Action = [
          "s3:GetObjectAttributes",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        Resource = "arn:${data.aws_partition.this.partition}:s3:::${var.namespace}-${terraform.workspace}-deployment/*"
      }
    ]
  })

  privileged_principal_actions = [
    "s3:GetObject",
    "s3:ListBucket",
    "s3:GetBucketLocation"
  ]
  cors_configuration = var.cors_configuration
  tags               = var.tags
}
