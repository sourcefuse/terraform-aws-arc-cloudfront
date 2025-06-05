################################################################################
## Tags Module
################################################################################

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    RepoName = "terraform-aws-refarch-cloudfront"
  }
}

################################################################################
## Module Cloudfront
################################################################################

module "cloudfront" {
  source  = "sourcefuse/arc-cloudfront/aws"
  version = "4.1.3"

  origins                = local.cloudfront_config.origins
  namespace              = local.cloudfront_config.namespace
  description            = local.cloudfront_config.description
  default_root_object    = local.cloudfront_config.default_root_object
  route53_root_domain    = local.cloudfront_config.route53_root_domain
  create_route53_records = local.cloudfront_config.create_route53_records
  aliases                = local.cloudfront_config.aliases
  enable_logging         = local.cloudfront_config.enable_logging
  default_cache_behavior = local.cloudfront_config.default_cache_behavior
  viewer_certificate     = local.cloudfront_config.viewer_certificate
  acm_details            = local.cloudfront_config.acm_details
  custom_error_responses = local.cloudfront_config.custom_error_responses
  price_class            = local.cloudfront_config.price_class

  providers = {
    aws.acm = aws.us-east-1
  }
}
