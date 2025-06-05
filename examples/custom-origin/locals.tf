locals {
  cloudfront_config = {
    origins = [{
      origin_type   = "custom"
      origin_id     = "dev-arc-cloudfront-custom-origin"
      domain_name   = "test.arc.arc-poc.link"
      bucket_name   = ""
      create_bucket = false
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }]

    namespace              = "dev"
    description            = "Custom origin Cloudront distribution for dev environment"
    default_root_object    = ""
    route53_root_domain    = "arc-poc.link"
    create_route53_records = true
    aliases                = ["test.arc.arc-poc.link"]
    enable_logging         = false

    default_cache_behavior = {
      origin_id                               = "dev-arc-cloudfront-custom-origin"
      allowed_methods                         = ["GET", "HEAD"]
      cached_methods                          = ["GET", "HEAD"]
      compress                                = false
      viewer_protocol_policy                  = "redirect-to-https"
      use_aws_managed_cache_policy            = true
      cache_policy_name                       = "CachingDisabled"
      use_aws_managed_origin_request_policy   = true
      origin_request_policy_name              = "AllViewer"
      response_headers_policy_name            = "SimpleCORS"
      use_aws_managed_response_headers_policy = true
    }

    viewer_certificate = {
      cloudfront_default_certificate = false
      minimum_protocol_version       = "TLSv1.2_2021"
      ssl_support_method             = "sni-only"
    }

    acm_details = {
      domain_name               = "test.arc.arc-poc.link"
      subject_alternative_names = ["test.arc.arc-poc.link"]
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
