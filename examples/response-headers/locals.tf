locals {
  cloudfront_config = {
    origins = [{
      origin_type   = "s3",
      origin_id     = "arc-dev-s3-origin",
      domain_name   = "",
      bucket_name   = "arc-dev-s3-origin-6781",
      create_bucket = true
    }]

    namespace              = "dev"
    description            = "Distribution with custom response headers policy"
    default_root_object    = "index.html"
    route53_root_domain    = null
    create_route53_records = false
    aliases                = []
    logging_config = {
      bucket  = "arc-dev-s3-origin-6718"
      enabled = true
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
      use_aws_managed_response_headers_policy = false
      response_headers_policy_name            = "security-headers-policy"
    }

    viewer_certificate = {
      cloudfront_default_certificate = true
      minimum_protocol_version       = "TLSv1.2_2021"
      ssl_support_method             = "sni-only"
    }

    response_headers_policy = {
      "security-headers-policy" = {
        name    = "security-headers-policy"
        comment = "Security headers policy for CloudFront"

        cors_config = {
          access_control_allow_credentials = false
          access_control_allow_headers = {
            items = ["*"]
          }
          access_control_allow_methods = {
            items = ["GET", "HEAD", "OPTIONS"]
          }
          access_control_allow_origins = {
            items = ["*"]
          }
          access_control_expose_headers = {
            items = ["ETag"]
          }
          access_control_max_age_sec = 86400
          origin_override            = false
        }

        security_headers_config = {
          content_type_options = {
            override = true
          }
          frame_options = {
            frame_option = "DENY"
            override     = true
          }
          referrer_policy = {
            referrer_policy = "strict-origin-when-cross-origin"
            override        = true
          }
          xss_protection = {
            mode_block = true
            protection = true
            override   = true
            report_uri = ""
          }
          strict_transport_security = {
            access_control_max_age_sec = "31536000"
            include_subdomains         = true
            preload                    = false
            override                   = true
          }
          content_security_policy = {
            content_security_policy = "default-src 'self'; script-src 'self' 'unsafe-inline'"
            override                = true
          }
        }

        custom_headers_config = {
          items = [
            {
              header   = "X-Custom-Header"
              override = true
              value    = "CustomValue"
            }
          ]
        }
      }
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
