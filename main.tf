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

resource "aws_cloudfront_response_headers_policy" "this" {
  for_each = var.response_headers_policy

  name    = each.value.name
  comment = each.value.comment

  dynamic "cors_config" {
    for_each = each.value.cors_config == null ? [] : [1]

    content {
      access_control_allow_credentials = try(each.value.cors_config.access_control_allow_credentials, false)

      access_control_allow_headers {
        items = try(each.value.cors_config.access_control_allow_headers.items, [])
      }

      access_control_allow_methods {
        items = try(each.value.cors_config.access_control_allow_methods.items, [])
      }

      access_control_allow_origins {
        items = try(each.value.cors_config.access_control_allow_origins.items, [])
      }

      access_control_expose_headers {
        items = try(each.value.cors_config.access_control_expose_headers.items, [])
      }

      access_control_max_age_sec = try(each.value.cors_config.access_control_max_age_sec, 600)
      origin_override            = try(each.value.cors_config.origin_override, true)

    }
  }


  dynamic "security_headers_config" {
    for_each = each.value.security_headers_config == null ? [] : [1]

    content {
      content_type_options {
        override = try(each.value.security_headers_config.content_type_options.override, false)
      }

      frame_options {
        frame_option = each.value.security_headers_config.frame_options.frame_option
        override     = try(each.value.security_headers_config.frame_options.override, false)
      }

      referrer_policy {
        referrer_policy = each.value.security_headers_config.referrer_policy.referrer_policy
        override        = try(each.value.security_headers_config.referrer_policy.override, false)
      }

      xss_protection {
        mode_block = try(each.value.security_headers_config.xss_protection.mode_block, false)
        protection = try(each.value.security_headers_config.xss_protection.protection, false)
        override   = try(each.value.security_headers_config.xss_protection.override, false)
        report_uri = try(each.value.security_headers_config.xss_protection.report_uri, "")
      }

      strict_transport_security {
        access_control_max_age_sec = try(each.value.security_headers_config.strict_transport_security.access_control_max_age_sec, "31536000")
        include_subdomains         = try(each.value.security_headers_config.strict_transport_security.include_subdomains, false)
        preload                    = try(each.value.security_headers_config.strict_transport_security.preload, false)
        override                   = try(each.value.security_headers_config.strict_transport_security.override, false)
      }

      content_security_policy {
        content_security_policy = try(each.value.security_headers_config.content_security_policy.content_security_policy, "31536000")
        override                = try(each.value.security_headers_config.content_security_policy.override, false)
      }


    }
  }

  dynamic "server_timing_headers_config" {
    for_each = each.value.server_timing_headers_config == null ? [] : [1]

    content {
      enabled       = try(each.value.server_timing_headers_config.enabled, false)
      sampling_rate = try(each.value.server_timing_headers_config.sampling_rate, 0)
    }
  }

  # TODO: Fix issue in setting below configs
  #   dynamic "remove_headers_config" {
  #     for_each = each.value.remove_headers_config == null ? [] : [each.value.remove_headers_config]

  #     content {
  #       dynamic "items" {
  #         for_each = remove_headers_config

  #         content {
  #           header = items
  #         }
  #       }
  #     }
  #   }


  #   dynamic "custom_headers_config" {
  #     for_each = each.value.custom_headers_config == null ? [] : [each.value.custom_headers_config]

  #     content {
  #       dynamic "items" {
  #         for_each = custom_headers_config

  #         content {
  #           header   = items.header
  #           override = try(items.override, false)
  #           value    = try(items.value, "none")
  #         }
  #       }

  #     }
  #   }

}

resource "aws_s3_bucket_policy" "cdn_bucket_policy" {
  for_each = {
    for index, origin in var.origins : origin.origin_id => origin
    if origin.origin_type == "s3"
  }

  bucket = each.value.create_bucket ? module.s3_bucket[each.value.origin_id].bucket_id : data.aws_s3_bucket.origin[each.value.origin_id].id

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
        Resource = each.value.create_bucket ? "${module.s3_bucket[each.value.origin_id].bucket_arn}/*" : "${data.aws_s3_bucket.origin[each.value.origin_id].arn}/*"
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

resource "aws_cloudfront_origin_access_control" "s3" {
  for_each = {
    for index, origin in var.origins : origin.origin_id => origin
    if origin.origin_type == "s3"
  }

  name                              = each.value.origin_id
  description                       = "Origin access control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  dynamic "origin" {
    for_each = {
      for index, origin in var.origins :
      origin.origin_id => origin
    }
    iterator = i

    content {
      domain_name              = i.value.origin_type == "s3" ? (i.value.create_bucket ? module.s3_bucket[i.value.origin_id].bucket_regional_domain_name : data.aws_s3_bucket.origin[i.value.origin_id].bucket_regional_domain_name) : i.value.domain_name
      origin_id                = i.value.origin_id
      origin_access_control_id = i.value.origin_type == "s3" ? aws_cloudfront_origin_access_control.s3[i.value.origin_id].id : null

      connection_attempts = i.value.connection_attempts
      connection_timeout  = i.value.connection_timeout

      dynamic "custom_origin_config" {
        for_each = i.value.custom_origin_config == null ? [] : [1]

        content {
          http_port                = i.value.custom_origin_config.http_port
          https_port               = i.value.custom_origin_config.https_port
          origin_protocol_policy   = i.value.custom_origin_config.origin_protocol_policy
          origin_ssl_protocols     = i.value.custom_origin_config.origin_ssl_protocols
          origin_keepalive_timeout = i.value.custom_origin_config.origin_keepalive_timeout
          origin_read_timeout      = i.value.custom_origin_config.origin_read_timeout
        }
      }

      dynamic "origin_shield" {
        for_each = try(i.value.custom_origin_config.enabled, null) == null || try(i.value.custom_origin_config.enabled, null) == false ? [] : [1]

        content {
          enabled              = try(i.value.custom_origin_config.enabled, null)
          origin_shield_region = try(i.value.custom_origin_config.origin_shield_region, null)
        }
      }
    }
  }

  comment             = var.description
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = var.price_class


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
    target_origin_id       = var.default_cache_behavior.origin_id
    compress               = lookup(var.default_cache_behavior, "compress", false)
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy

    cache_policy_id            = var.default_cache_behavior.use_aws_managed_cache_policy ? local.managed_cache_policies[var.default_cache_behavior.cache_policy_name] : aws_cloudfront_cache_policy.this[var.default_cache_behavior.cache_policy_name].id
    origin_request_policy_id   = var.default_cache_behavior.use_aws_managed_origin_request_policy ? local.managed_origin_request_policies[var.default_cache_behavior.origin_request_policy_name] : (var.default_cache_behavior.origin_request_policy_name == null ? null : aws_cloudfront_origin_request_policy.this[var.default_cache_behavior.origin_request_policy_name].id)
    response_headers_policy_id = var.default_cache_behavior.use_aws_managed_response_headers_policy ? local.managed_response_header_policies[var.default_cache_behavior.response_headers_policy_name] : (var.default_cache_behavior.response_headers_policy_name == null ? null : aws_cloudfront_response_headers_policy.this[var.default_cache_behavior.response_headers_policy_name].id)

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
      path_pattern           = i.value.path_pattern
      allowed_methods        = i.value.allowed_methods
      cached_methods         = i.value.cached_methods
      target_origin_id       = i.value.origin_id
      compress               = lookup(i.value, "compress", false)
      viewer_protocol_policy = i.value.viewer_protocol_policy

      cache_policy_id            = i.value.use_aws_managed_cache_policy ? local.managed_cache_policies[i.value.cache_policy_name] : aws_cloudfront_cache_policy.this[i.value.cache_policy_name].id
      origin_request_policy_id   = i.value.use_aws_managed_origin_request_policy ? local.managed_origin_request_policies[i.value.origin_request_policy_name] : (i.value.origin_request_policy_name == null ? null : aws_cloudfront_origin_request_policy.this[i.value.origin_request_policy_name].id)
      response_headers_policy_id = i.value.use_aws_managed_response_headers_policy ? local.managed_response_header_policies[i.value.response_headers_policy_name] : (i.value.response_headers_policy_name == null ? null : aws_cloudfront_response_headers_policy.this[i.value.response_headers_policy_name].id)


      dynamic "lambda_function_association" {
        for_each = i.value.lambda_function_association == null ? {} : {
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
        for_each = i.value.function_association == null ? {} : {
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

  web_acl_id       = var.web_acl_id
  retain_on_delete = var.retain_on_delete
}
