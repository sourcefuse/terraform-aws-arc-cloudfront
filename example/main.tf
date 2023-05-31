module "cloudfront" {
  source = "../"
  # Pass the variable values
  environment    = "dev"
  project_name   = "test"
  bucket_name    = "test-cloudfront-arc"
  namespace      = "test"
  description    = "This is a test Cloudfront distribution"
  route53_domain = "sfrefarch.com"
  acm_domain     = "cf.sfrefarch.com"
  aliases        = ["cf.sfrefarch.com"]
  enable_route53 = true

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
    cloudfront_default_certificate = false // false :  will create ACM certificate with acm_domain
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  cache_policy = {
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
  }

}
