terraform {
  required_version = ">= 1.0, < 2.0"
}

module "s3_cloudfront_site" {
  source                         = "../"
  certificate_arn                = var.certificate_arn
  environment                    = var.environment
  sub_domain                     = var.sub_domain
  domain                         = var.domain
  responsible_party              = var.responsible_party
  versioning_enabled             = var.versioning_enabled
  default_object                 = var.default_object
  default_error_object           = var.default_error_object
  zone_id                        = var.zone_id
  dynamic_default_cache_behavior = var.dynamic_default_cache_behavior
}
