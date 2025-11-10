################################################################################
## Tags Module
################################################################################

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    RepoName = "terraform-aws-arc-cloudfront"
  }
}

################################################################################
## Module Cloudfront with Origin Groups for DR
################################################################################

module "cloudfront" {
  source = "../../"

  providers = {
    aws.acm = aws.acm
  }

  origins = [
    {
      origin_type   = "s3"
      origin_id     = "primary-origin"
      domain_name   = ""
      bucket_name   = "arc-poc-primary-bucket"
      create_bucket = true
    },
    {
      origin_type   = "s3"
      origin_id     = "secondary-origin"
      domain_name   = ""
      bucket_name   = "arc-pocsecondary-bucket"
      create_bucket = true
    }
  ]

  origin_groups = [
    {
      origin_id = "failover-group"
      failover_criteria = {
        status_codes = [403, 404, 500, 502, 503, 504]
      }
      members = [
        {
          origin_id = "primary-origin"
        },
        {
          origin_id = "secondary-origin"
        }
      ]
    }
  ]

  namespace              = "dr-example"
  description            = "CloudFront distribution with origin group for DR"
  route53_root_domain    = var.route53_root_domain
  create_route53_records = var.create_route53_records
  aliases                = []
  enable_logging         = false

  default_cache_behavior = {
    origin_id                             = "failover-group"
    allowed_methods                       = ["GET", "HEAD", "OPTIONS"]
    cached_methods                        = ["GET", "HEAD"]
    compress                              = true
    viewer_protocol_policy                = "redirect-to-https"
    use_aws_managed_cache_policy          = true
    cache_policy_name                     = "CachingOptimized"
    use_aws_managed_origin_request_policy = true
    origin_request_policy_name            = "CORS-S3Origin"
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  tags = module.tags.tags
}
