region      = "us-east-1"
environment = "dev"
namespace   = "arc"


distribution_data = [

  ###### Cloudfront S3 Origin ######
  {
    id = "arc-dev-s3-origin",
    origins = [{
      origin_type   = "s3",
      origin_id     = "arc-dev-s3-origin",
      domain_name   = "",
      bucket_name   = "arc-dev-s3-origin",
      create_bucket = false
      }
    ],
    namespace              = "dev",
    description            = "Distribution for arc dev",
    default_root_object    = "index.html"
    route53_root_domain    = "arc-poc.link"
    create_route53_records = true,
    aliases                = ["test-s3-origin.arc-poc.link"],
    enable_logging         = false,
    default_cache_behavior = {
      origin_id              = "arc-dev-s3-origin"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = false
      viewer_protocol_policy = "redirect-to-https"

      use_aws_managed_cache_policy            = true
      cache_policy_name                       = "CachingOptimized"
      use_aws_managed_origin_request_policy   = true
      origin_request_policy_name              = "CORS-S3Origin"
      response_headers_policy_name            = "CORS-and-SecurityHeadersPolicy"
      use_aws_managed_response_headers_policy = true
    },
    viewer_certificate = {
      cloudfront_default_certificate = false // false :  It will create ACM certificate with details provided in acm_details
      minimum_protocol_version       = "TLSv1.2_2021"
      ssl_support_method             = "sni-only"
    },

    acm_details = {
      domain_name               = "test-s3-origin.arc-poc.link",
      subject_alternative_names = ["test-s3-origin.arc-poc.link"]
    },
    custom_error_responses = [{
      error_caching_min_ttl = 300,
      error_code            = "403",
      response_code         = "200",
      response_page_path    = "/index.html"
      },
      {
        error_caching_min_ttl = 10,
        error_code            = "404",
        response_code         = "200",
        response_page_path    = "/index.html"
    }],

    price_class = "PriceClass_All"

  }
]