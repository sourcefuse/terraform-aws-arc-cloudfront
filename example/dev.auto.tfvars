certificate_arn      = "arn:aws:acm:us-east-1:757583164619:certificate/c29d5333-37c8-42a8-ba3c-d0cd6cd5db4b"
environment          = "dev"
sub_domain           = "sf-s3-origin-site"
domain               = "sfrefarch.com"
responsible_party    = "Sourcefuse"
default_object       = "index.html"
default_error_object = "error.html"
versioning_enabled   = true
zone_id              = "Z019267039CEOT4DT8S38"

dynamic_default_cache_behavior = [
  {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "sf-s3-origin-site.sfrefarch.com"
    compress               = false
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
]
