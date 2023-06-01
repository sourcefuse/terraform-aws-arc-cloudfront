variable "aliases" {
  description = "Fully qualified domain name for site being hosted"
  type        = list(string)
}

variable "description" {
  description = "CloudFron destribution description"
  type        = string
}

variable "route53_root_domain" {
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

variable "tags" {
  type        = map(string)
  description = "Tags for AWS resources"
  default     = {}
}


variable "namespace" {
  type        = string
  description = "Namespace for the resources."
  default     = null
}

variable "create_route53_records" {
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
    cloudfront_default_certificate = bool,
    minimum_protocol_version       = string,
    ssl_support_method             = string
  })
  description = "The SSL configuration for this distribution "
  default = {
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }
}

variable "s3_kms_details" {
  type = object({
    kms_key_administrators = list(string), // "Environment where deploying,List of AWS arns that will have permissions to use kms key"
    kms_key_users          = list(string), // "Environment where deploying,List of AWS arns that will have permissions to use kms key"
  })
  description = "KMS details for S3 encryption"
  default = {
    kms_key_administrators = [],
    kms_key_users          = []
  }
}

variable "enable_logging" {
  type        = bool
  description = "Enable logging for Clouffront destribution, this will create new S3 bucket"
  default     = false
}

variable "acm_details" {
  type = object({
    domain_name               = string,
    subject_alternative_names = list(string),
  })
  description = "Details required for creating certificate"
  default = {
    domain_name               = "test.com",
    subject_alternative_names = ["www.test.com"]
  }
}

variable "route53_record_ttl" {
  type        = string
  description = "TTL for Route53 record"
  default     = 60
}
