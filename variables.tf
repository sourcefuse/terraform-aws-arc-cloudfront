variable "sub_domain" {
  description = "Fully qualified domain name for site being hosted"
  type        = string
}

variable "aliases" {
  description = "Fully qualified domain name for site being hosted"
  type        = list(string)
}

variable "domain" {
  description = "Domain to add to route 53 as alias to distribution"
  type        = string
}

variable "default_cache_behavior" {
  description = "Set the cache behavior for the distribution here"
  type = object({
    allowed_methods        = list(string)
    cached_methods         = list(string)
    target_origin_id       = optional(string)
    compress               = bool
    viewer_protocol_policy = string
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number
  })
}

variable "website_redirect_all_requests_to" {
  type = list(object({
    host_name = string
    protocol  = string
  }))
  description = "If provided, all website requests will be redirected to the specified host name and protocol"
  default     = []

  validation {
    condition     = length(var.website_redirect_all_requests_to) < 2
    error_message = "Only 1 website_redirect_all_requests_to is allowed."
  }
}

variable "website_configuration" {
  type = list(object({
    index_document = string
    error_document = string
    routing_rules = list(object({
      condition = object({
        http_error_code_returned_equals = string
        key_prefix_equals               = string
      })
      redirect = object({
        host_name               = string
        http_redirect_code      = string
        protocol                = string
        replace_key_prefix_with = string
        replace_key_with        = string
      })
    }))
  }))
  description = "Specifies the static website hosting configuration object"
  default     = []

  validation {
    condition     = length(var.website_configuration) < 2
    error_message = "Only 1 website_configuration is allowed."
  }
}

variable "cors_configuration" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = null

  description = "Specifies the allowed headers, methods, origins and exposed headers when using CORS on this bucket"
}

variable "bucket_name" {
  type        = string
  default     = null
  description = "Bucket name. If provided, the bucket will be created with this name instead of generating the name from the context"
}

variable "project_name" {
  type        = string
  description = "Name of the project."
  default     = "cloudfront-iac"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Name of the environment resources belong to."
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
  default     = null
}

variable "enable_route53" {
  type        = bool
  description = "made optional route53"
  default     = false
}

variable "geo_restriction" {
  type = object({
    restriction_type = string,
    locations        = list(string)
  })
  description = "Geographic restriction"
  default = {
    restriction_type = "none"
    locations        = []
  }
}

variable "cache_policy" {
  type = object(
    {
      default_ttl = number,
      max_ttl     = number,
      min_ttl     = number,
      cookies_config = object({
        cookie_behavior = string
        items           = list(string)
      }),
      headers_config = object({
        header_behavior = string
        items           = list(string)
      }),
      query_strings_config = object({
        query_string_behavior = string
        items                 = list(string)
      })
    }
  )
  description = "Origin request policy"
  default = {
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

variable "origin_request_policy" {
  type = object({
    cookies_config = object({
      cookie_behavior = string
      items           = list(string)
    }),
    headers_config = object({
      header_behavior = string
      items           = list(string)
    }),
    query_strings_config = object({
      query_string_behavior = string
      items                 = list(string)
    })
  })
  description = "Origin request policy"
  default = {
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
  }
}


variable "viewer_certificate" {
  type = object({
    acm_certificate_arn            = string,
    cloudfront_default_certificate = bool,
    minimum_protocol_version       = string,
    ssl_support_method             = string
  })
  description = "The SSL configuration for this distribution "
  default = {
    acm_certificate_arn            = ""
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }
}
