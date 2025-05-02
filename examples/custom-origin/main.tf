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

  for_each               = { for idx, dist in local.distribution_data : tostring(idx) => dist }
  origins                = each.value.origins
  namespace              = each.value.namespace
  description            = each.value.description
  default_root_object    = each.value.default_root_object
  route53_root_domain    = each.value.route53_root_domain
  create_route53_records = each.value.create_route53_records
  aliases                = each.value.aliases
  enable_logging         = each.value.enable_logging
  default_cache_behavior = each.value.default_cache_behavior
  viewer_certificate     = each.value.viewer_certificate
  acm_details            = each.value.acm_details
  custom_error_responses = each.value.custom_error_responses
  price_class            = each.value.price_class
  providers = {
    aws.acm = aws.us-east-1 # Specify the provider for this module
  }

  tags = module.tags.tags
}
