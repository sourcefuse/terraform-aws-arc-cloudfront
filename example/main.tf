module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = "dev"
  project     = "test"

  extra_tags = {
    RepoName = "terraform-aws-refarch-cloudfront"
  }
}

module "cloudfront" {
  source  = "sourcefuse/arc-cloudfront/aws"
  version = "4.0.6"
  providers = {
    aws.acm = aws.acm // Certificate has to be created in us-east-1 region
  }

  origins = [{
    origin_type   = "custom",
    origin_id     = "cloudfront-arc",
    domain_name   = "test.wpengine.com",
    bucket_name   = "",
    create_bucket = false,
    custom_origin_config = {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1"]
    }

    }
  ]

  namespace              = "test"
  description            = "This is a test Cloudfront distribution"
  route53_root_domain    = "sfrefarch.com" // Used to fetch the Hosted Zone
  create_route53_records = var.create_route53_records
  aliases                = ["cf.sfrefarch.com", "www.cf.sfrefarch.com", "test.sfrefarch.com", "*.sfrefarch.com", "test1.sfrefarch.com"]
  enable_logging         = var.enable_logging // Create a new S3 bucket for storing Cloudfront logs

  default_cache_behavior = {
    origin_id                               = "cloudfront-arc",
    allowed_methods                         = ["GET", "HEAD"]
    cached_methods                          = ["GET", "HEAD"]
    compress                                = false
    viewer_protocol_policy                  = "redirect-to-https"
    use_aws_managed_response_headers_policy = false
    response_headers_policy_name            = "test-security-headers-policy"

    use_aws_managed_cache_policy          = true
    cache_policy_name                     = "CachingOptimized"
    use_aws_managed_origin_request_policy = true
    origin_request_policy_name            = "CORS-S3Origin" // It can be custom or aws managed policy name , if custom origin_request_policies variable key should match
    lambda_function_association = [{
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.this.qualified_arn
      include_body = true
    }]

  }

  cache_behaviors = [
    {
      origin_id              = "cloudfront-arc",
      path_pattern           = "/content/immutable/*"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = false
      viewer_protocol_policy = "redirect-to-https"

      use_aws_managed_cache_policy          = false
      cache_policy_name                     = "cache-policy-1" // Note: This has to match cache_polices mentioned below
      use_aws_managed_origin_request_policy = false
      origin_request_policy_name            = "origin-req-policy-1" // Note: This has to match origin_request_policies mentioned below

      function_association = [
        {
          event_type   = "viewer-request"
          function_arn = aws_cloudfront_function.this.arn
        }
      ]
    }
  ]

  viewer_certificate = {
    cloudfront_default_certificate = false // false :  It will create ACM certificate with details provided in acm_details
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  acm_details = {
    domain_name               = "*.sfrefarch.com",
    subject_alternative_names = ["www.cf.sfrefarch.com"]
  }

  cache_policies = {
    "cache-policy-1" = {
      default_ttl = 86400,
      max_ttl     = 31536000,
      min_ttl     = 0,
      cookies_config = {
        cookie_behavior = "none",
        items           = []
      },
      headers_config = {
        header_behavior = "whitelist",
        items           = ["Authorization", "Origin", "Accept", "Access-Control-Request-Method", "Access-Control-Request-Headers", "Referer"]
      },
      query_string_behavior = {
        header_behavior = "none",
        items           = []
      },
      query_strings_config = {
        query_string_behavior = "none",
        items                 = []
      }
  } }


  origin_request_policies = {
    "origin-req-policy-1" = {
      cookies_config = {
        cookie_behavior = "none",
        items           = []
      },
      headers_config = {
        header_behavior = "whitelist",
        items = ["Accept", "Accept-Charset", "Accept-Datetime", "Accept-Language",
          "Access-Control-Request-Method", "Access-Control-Request-Headers", "CloudFront-Forwarded-Proto", "CloudFront-Is-Android-Viewer",
        "CloudFront-Is-Desktop-Viewer", "CloudFront-Is-IOS-Viewer"]
      },
      query_strings_config = {
        query_string_behavior = "none",
        items                 = []
      }
  } }

  custom_error_responses = [{
    error_caching_min_ttl = 10,
    error_code            = "404", // should be unique
    response_code         = "404",
    response_page_path    = "/custom_404.html"
  }]

  s3_kms_details = {
    s3_bucket_encryption_type = "SSE-S3", //Encryption for S3 bucket , options : `SSE-S3` , `SSE-KMS`
    kms_key_administrators    = [],
    kms_key_users             = [], // Note :- Add users/roles who wanted to read/write to S3 bucket
    kms_key_arn               = null
  }

  response_headers_policy = local.response_headers_policy

  tags = module.tags.tags

}


locals {
  response_headers_policy = {
    "test-security-headers-policy" = {
      name = "test-security-headers-policy"
      cors_config = {
        access_control_allow_credentials = true
        access_control_allow_headers = {
          items = ["test"]
        }
        access_control_allow_methods = {
          items = ["GET"]
        }
        access_control_allow_origins = {
          items = ["test.example.comtest"]
        }
        access_control_expose_headers = {
          items = []
        }
        access_control_max_age_sec = 600
        origin_override            = true
      }

      security_headers_config = {
        content_type_options = {
          override = false
        }
        frame_options = {
          frame_option = "SAMEORIGIN"
          override     = false
        }
        referrer_policy = {
          referrer_policy = "origin-when-cross-origin"
          override        = true
        }
        xss_protection = {
          mode_block = false
          protection = true
          override   = false
          report_uri = ""
        }
        strict_transport_security = {
          access_control_max_age_sec = "31536000"
          include_subdomains         = true
          preload                    = false
          override                   = false
        }
        content_security_policy = {
          content_security_policy = "frame-ancestors 'self'"
          override                = false
        }
      }
    }
  }
}
