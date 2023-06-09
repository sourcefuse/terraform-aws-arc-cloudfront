locals {
  origin_id   = "${var.tags["Environment"]}-${var.bucket_name}"
  environment = var.tags["Environment"]
  // Remove domains starting with *, eg. *.test.com
  aliases                    = [for alias in var.aliases : alias if length(regexall("[*]+", alias)) == 0]
  origin_access_control_name = var.create_bucket ? "${local.environment}-${module.s3_bucket[0].bucket_regional_domain_name}-${var.origin_access_control_id}" : "${local.environment}-${data.aws_s3_bucket.origin[0].bucket_regional_domain_name}-${var.origin_access_control_id}"
  domain_name                = var.create_bucket ? module.s3_bucket[0].bucket_regional_domain_name : data.aws_s3_bucket.origin[0].bucket_regional_domain_name
}
