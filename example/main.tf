terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "cloudfront" {
  source = "../"
  # Pass the variable values
  environment                    = var.environment
  project_name                   = var.project_name
  bucket_name                    = var.bucket_name
  namespace                      = var.namespace
  sub_domain                     = var.sub_domain
  domain                         = var.domain
  custom_domains                 = var.custom_domains
  dynamic_default_cache_behavior = var.dynamic_default_cache_behavior
  enable_route53                 = var.enable_route53
}

# module "s3_cloudfront_site" {
#   source                         = "../"
#   certificate_arn                = var.certificate_arn
#   environment                    = var.environment
#   sub_domain                     = var.sub_domain
#   domain                         = var.domain
#   responsible_party              = var.responsible_party
#   versioning_enabled             = var.versioning_enabled
#   default_object                 = var.default_object
#   default_error_object           = var.default_error_object
#   zone_id                        = var.zone_id
#   dynamic_default_cache_behavior = var.dynamic_default_cache_behavior
# }
