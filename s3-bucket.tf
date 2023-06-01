##################################################################################
# s3 Module #
##################################################################################

// Module creates KMS and its related resources
module "kms" {
  source                  = "./modules/kms"
  environment             = local.environment
  alias                   = "${local.environment}/s3/${var.bucket_name}"
  kms_key_administrators  = var.s3_kms_details.kms_key_administrators
  kms_key_users           = var.s3_kms_details.kms_key_users
  deletion_window_in_days = 7
  aws_services            = ["s3.amazonaws.com", "cloudfront.amazonaws.com"]
  tags                    = var.tags
}

module "s3_bucket" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.0.0"

  bucket_name = "${local.environment}-${var.bucket_name}"
  environment = local.environment
  namespace   = var.namespace

  enabled            = true
  acl                = "private"
  versioning_enabled = true
  bucket_key_enabled = true
  kms_master_key_arn = module.kms.key_arn
  sse_algorithm      = "aws:kms"

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
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.0.0"

  count = var.enable_logging ? 1 : 0

  bucket_name = "${local.environment}-${var.bucket_name}-logging"
  environment = local.environment
  namespace   = var.namespace

  acl                = "log-delivery-write"
  versioning_enabled = false
  bucket_key_enabled = true
  kms_master_key_arn = module.kms.key_arn
  sse_algorithm      = "aws:kms"

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
