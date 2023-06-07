data "aws_partition" "this" {}

data "aws_caller_identity" "this" {}

resource "aws_cloudfront_cache_policy" "this" {
  for_each = var.cache_policies

  name        = "${local.environment}-${each.key}-cache-policy"
  comment     = "Cache policy"
  default_ttl = each.value.default_ttl
  max_ttl     = each.value.max_ttl
  min_ttl     = each.value.min_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = each.value.cookies_config.cookie_behavior
      cookies {
        items = each.value.cookies_config.items
      }
    }
    headers_config {
      header_behavior = each.value.cookies_config.cookie_behavior
      headers {
        items = each.value.cookies_config.items
      }
    }
    query_strings_config {
      query_string_behavior = each.value.query_strings_config.query_string_behavior
      query_strings {
        items = each.value.query_strings_config.items
      }
    }
  }

}

resource "aws_cloudfront_origin_request_policy" "this" {
  for_each = var.origin_request_policies

  name    = "${local.environment}-${each.key}-origin-request-policy"
  comment = "Origin request policy"
  cookies_config {
    cookie_behavior = each.value.cookies_config.cookie_behavior
    cookies {
      items = each.value.cookies_config.items
    }
  }
  headers_config {
    header_behavior = each.value.headers_config.header_behavior
    headers {
      items = each.value.headers_config.items
    }
  }
  query_strings_config {
    query_string_behavior = each.value.query_strings_config.query_string_behavior
    query_strings {
      items = each.value.query_strings_config.items
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
  default_root_object = var.default_root_object


  dynamic "custom_error_response" {
    for_each = {
      for index, err_resp in var.custom_error_responses :
      err_resp.error_code => err_resp
    }
    iterator = i

    content {
      error_caching_min_ttl = lookup(i.value, "error_caching_min_ttl", 0)
      error_code            = i.value.error_code
      response_code         = lookup(i.value, "response_code", "")
      response_page_path    = lookup(i.value, "response_page_path", "")
    }
  }


  default_cache_behavior {
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    target_origin_id       = local.origin_id
    compress               = lookup(var.default_cache_behavior, "compress", false)
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy

    cache_policy_id          = var.default_cache_behavior.use_aws_managed_cache_policy ? local.managed_cache_policies[var.default_cache_behavior.cache_policy_name] : aws_cloudfront_cache_policy.this[var.default_cache_behavior.cache_policy_name].id
    origin_request_policy_id = var.default_cache_behavior.use_aws_managed_origin_request_policy ? local.managed_origin_request_policies[var.default_cache_behavior.origin_request_policy_name] : (var.default_cache_behavior.origin_request_policy_name == null ? null : aws_cloudfront_origin_request_policy.this[var.default_cache_behavior.origin_request_policy_name].id)


    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_association == null ? [] : var.default_cache_behavior.lambda_function_association
      iterator = i

      content {
        event_type   = i.value.event_type
        lambda_arn   = i.value.lambda_arn
        include_body = i.value.include_body
      }
    }

    dynamic "function_association" {
      for_each = var.default_cache_behavior.function_association == null ? [] : var.default_cache_behavior.function_association
      iterator = i

      content {
        event_type   = i.value.event_type
        function_arn = i.value.function_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = {
      for index, cache in var.cache_behaviors :
      cache.path_pattern => cache
    }

    iterator = i

    content {
      path_pattern           = i.value.allowed_methods
      allowed_methods        = i.value.allowed_methods
      cached_methods         = i.value.cached_methods
      target_origin_id       = local.origin_id
      compress               = lookup(i.value, "compress", false)
      viewer_protocol_policy = i.value.viewer_protocol_policy

      cache_policy_id          = i.value.use_aws_managed_cache_policy ? local.managed_cache_policies[i.value.cache_policy_name] : aws_cloudfront_cache_policy.this[i.value.cache_policy_name].id
      origin_request_policy_id = i.value.use_aws_managed_origin_request_policy ? local.managed_origin_request_policies[i.value.origin_request_policy_name] : (i.value.origin_request_policy_name == null ? null : aws_cloudfront_origin_request_policy.this[i.value.origin_request_policy_name].id)


      dynamic "lambda_function_association" {
        for_each = {
          for index, function in i.value.lambda_function_association :
          function.event_type => function
        }
        iterator = j

        content {
          event_type   = j.value.event_type
          lambda_arn   = j.value.lambda_arn
          include_body = j.value.include_body
        }
      }

      dynamic "function_association" {
        for_each = {
          for index, function in i.value.function_association :
          function.event_type => function
        }
        iterator = j

        content {
          event_type   = j.value.event_type
          function_arn = j.value.function_arn
        }
      }
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
