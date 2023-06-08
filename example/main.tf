module "tags" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags?ref=1.1.0"

  environment = "dev"
  project     = "test"

  extra_tags = {
    RepoName = "terraform-aws-refarch-cloudfront"
  }
}

module "cloudfront" {
  source = "../"

  bucket_name            = "test-cloudfront-arc"
  namespace              = "test"
  description            = "This is a test Cloudfront distribution"
  route53_root_domain    = "sfrefarch.com" // Used to fetch the Hosted Zone
  create_route53_records = var.create_route53_records
  aliases                = ["cf.sfrefarch.com", "www.cf.sfrefarch.com", "test.sfrefarch.com", "*.sfrefarch.com", "test1.sfrefarch.com"]
  enable_logging         = var.enable_logging // Create a new S3 bucket for storing Cloudfront logs

  default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = false
    viewer_protocol_policy = "redirect-to-https"

    use_aws_managed_cache_policy          = true
    cache_policy_name                     = "CachingOptimized"
    use_aws_managed_origin_request_policy = true
    origin_request_policy_name            = "CORS-S3Origin" // It can be custom or aws managed policy name , if custom origin_request_policies variable key should match
    # lambda_function_association = [{
    #   event_type   = "viewer-request"
    #   lambda_arn   = aws_lambda_function.this.qualified_arn
    #   include_body = true
    # }]

  }

  cache_behaviors = [
    {
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

  tags = module.tags.tags

}
