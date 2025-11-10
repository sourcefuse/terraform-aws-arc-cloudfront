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
## Module Cloudfront with Response Headers Policy
################################################################################

module "cloudfront" {
  source = "../../"

  origins                 = local.cloudfront_config.origins
  namespace               = local.cloudfront_config.namespace
  description             = local.cloudfront_config.description
  default_root_object     = local.cloudfront_config.default_root_object
  route53_root_domain     = local.cloudfront_config.route53_root_domain
  create_route53_records  = local.cloudfront_config.create_route53_records
  aliases                 = local.cloudfront_config.aliases
  logging_config          = local.cloudfront_config.logging_config
  default_cache_behavior  = local.cloudfront_config.default_cache_behavior
  viewer_certificate      = local.cloudfront_config.viewer_certificate
  custom_error_responses  = local.cloudfront_config.custom_error_responses
  price_class             = local.cloudfront_config.price_class
  response_headers_policy = local.cloudfront_config.response_headers_policy

  providers = {
    aws.acm = aws.acm
  }

  tags = module.tags.tags
}
