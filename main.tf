data "aws_partition" "this" {}

data "aws_caller_identity" "this" {}

resource "aws_cloudfront_cache_policy" "this" {
  name        = "${local.environment}-${module.s3_bucket.bucket_id}-cache-policy"
  comment     = "Cache policy"
  default_ttl = var.cache_policy.default_ttl
  max_ttl     = var.cache_policy.max_ttl
  min_ttl     = var.cache_policy.min_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = var.cache_policy.cookies_config.cookie_behavior
      cookies {
        items = var.cache_policy.cookies_config.items
      }
    }
    headers_config {
      header_behavior = var.cache_policy.cookies_config.cookie_behavior
      headers {
        items = var.cache_policy.cookies_config.items
      }
    }
    query_strings_config {
      query_string_behavior = var.cache_policy.query_strings_config.query_string_behavior
      query_strings {
        items = var.cache_policy.query_strings_config.items
      }
    }
  }

}

resource "aws_cloudfront_origin_request_policy" "this" {
  name    = "${local.environment}-${module.s3_bucket.bucket_id}-origin-request-policy"
  comment = "Origin request policy"
  cookies_config {
    cookie_behavior = var.origin_request_policy.cookies_config.cookie_behavior
    cookies {
      items = var.origin_request_policy.cookies_config.items
    }
  }
  headers_config {
    header_behavior = var.origin_request_policy.headers_config.header_behavior
    headers {
      items = var.origin_request_policy.headers_config.items
    }
  }
  query_strings_config {
    query_string_behavior = var.origin_request_policy.query_strings_config.query_string_behavior
    query_strings {
      items = var.origin_request_policy.query_strings_config.items
    }
  }
}


resource "aws_s3_bucket_policy" "cdn_bucket_policy" {
  bucket = module.s3_bucket.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_bucket.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

##################################################################################
# CDN #
##################################################################################

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${local.environment}-cf-origin-access-control"
  description                       = "Origin access control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name              = module.s3_bucket.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  comment             = var.description
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  dynamic "default_cache_behavior" {
    for_each = [var.default_cache_behavior]
    iterator = i

    content {
      allowed_methods        = i.value.allowed_methods
      cached_methods         = i.value.cached_methods
      target_origin_id       = local.origin_id
      compress               = lookup(i.value, "compress", false)
      viewer_protocol_policy = i.value.viewer_protocol_policy
      min_ttl                = lookup(i.value, "min_ttl", 0)
      default_ttl            = lookup(i.value, "default_ttl", 3600)
      max_ttl                = lookup(i.value, "max_ttl", 86400)

      cache_policy_id          = aws_cloudfront_cache_policy.this.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.this.id

    }
  }

  aliases = var.aliases

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []

    content {
      include_cookies = false
      bucket          = module.s3_bucket_logs[0].bucket_domain_name
      prefix          = local.environment
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.viewer_certificate.cloudfront_default_certificate ? null : aws_acm_certificate.this[0].arn
    cloudfront_default_certificate = var.viewer_certificate.cloudfront_default_certificate
    minimum_protocol_version       = var.viewer_certificate.minimum_protocol_version
    ssl_support_method             = var.viewer_certificate.ssl_support_method
  }

  tags = var.tags

  depends_on = [aws_cloudfront_origin_access_control.this]
}
