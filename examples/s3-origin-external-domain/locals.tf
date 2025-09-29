locals {
  cloudfront_config = {
    origins = [{
      origin_type   = "s3",
      origin_id     = "arc-dev-s3-origin",
      domain_name   = "",
      bucket_name   = "arc-dev-s3-origin",
      create_bucket = false
    }]

    namespace           = "dev"
    description         = "Distribution for arc dev"
    default_root_object = "index.html"
    enable_logging      = false

    # To avoid creating ACM certificate and route53 records
    create_route53_records = false
    aliases                = []
    route53_root_domain    = "arc-poc.link"
    acm_details = {
      domain_name = null
    }


    default_cache_behavior = {
      origin_id                               = "arc-dev-s3-origin"
      allowed_methods                         = ["GET", "HEAD"]
      cached_methods                          = ["GET", "HEAD"]
      compress                                = false
      viewer_protocol_policy                  = "redirect-to-https"
      use_aws_managed_cache_policy            = true
      cache_policy_name                       = "CachingOptimized"
      use_aws_managed_origin_request_policy   = true
      origin_request_policy_name              = "CORS-S3Origin"
      use_aws_managed_response_headers_policy = true
      response_headers_policy_name            = "CORS-and-SecurityHeadersPolicy"
    }

    viewer_certificate = {
      cloudfront_default_certificate = true
      minimum_protocol_version       = "TLSv1.2_2021"
      ssl_support_method             = "sni-only"
    }

    custom_error_responses = [
      {
        error_caching_min_ttl = 300
        error_code            = "403"
        response_code         = "200"
        response_page_path    = "/index.html"
      },
      {
        error_caching_min_ttl = 10
        error_code            = "404"
        response_code         = "200"
        response_page_path    = "/index.html"
      }
    ]

    price_class = "PriceClass_All"
  }
}
