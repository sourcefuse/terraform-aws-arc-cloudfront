module "cloudfront" {
  source = "../"
  # Pass the variable values
  environment    = "dev"
  project_name   = "test"
  bucket_name    = "test-cloudfront-arc"
  namespace      = "test"
  sub_domain     = ""
  domain         = ""
  aliases        = []
  enable_route53 = false

  default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "dummy"
    compress               = false
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  viewer_certificate = {
    acm_certificate_arn            = ""
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }


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
