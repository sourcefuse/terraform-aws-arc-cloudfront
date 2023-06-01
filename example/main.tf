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
  create_route53_records = true
  aliases                = ["cf.sfrefarch.com", "www.cf.sfrefarch.com"]
  enable_logging         = true // Create a new S3 bucket for storing Cloudfront logs

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
    cloudfront_default_certificate = false // false :  It will create ACM certificate with details provided in acm_details
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  acm_details = {
    domain_name               = "cf.sfrefarch.com",
    subject_alternative_names = ["www.cf.sfrefarch.com"]
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

  s3_kms_details = {
    kms_key_administrators = [],
    kms_key_users          = ["arn:aws:iam::757583164619:role/sourcefuse-poc-2-admin-role"] // Note :- Add users/roles who wanted to read/write to S3 bucket
  }

  tags = module.tags.tags

}
