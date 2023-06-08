variable "aliases" {
  description = "Fully qualified domain name for site being hosted"
  type        = list(string)
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = " Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
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
  description = "Default cache behavior for the distribution"
  type = object({
    allowed_methods = list(string)
    cached_methods  = list(string)
    function_association = optional(list(object({ // A config block that triggers a lambda function with specific actions (maximum 4).
      event_type   = string,                      // Specific event to trigger this function. Valid values: viewer-request or viewer-response.
      function_arn = string
    })))
    lambda_function_association = optional(list(object({ // A config block that triggers a lambda function with specific actions (maximum 4).
      event_type   = string,
      lambda_arn   = string,
      include_body = bool // When set to true it exposes the request body to the lambda function.
    })))
    use_aws_managed_cache_policy          = bool,
    cache_policy_name                     = string, // It can be custom or aws managed policy name , if custom cache_policies variable key should match
    use_aws_managed_origin_request_policy = optional(bool),
    origin_request_policy_name            = optional(string), // It can be custom or aws managed policy name , if custom origin_request_policies variable key should match
    compress                              = bool
    viewer_protocol_policy                = string
  })
}

variable "cache_behaviors" {
  description = "Set the cache behaviors for the distribution , Note:-  You cannot use an origin request policy in a cache behavior without a cache policy."
  type = list(object({
    path_pattern    = string
    allowed_methods = list(string)
    cached_methods  = list(string)
    function_association = optional(list(object({ // Specific event to trigger this function. Valid values: viewer-request or viewer-response.
      event_type   = string,
      function_arn = string
    })))
    lambda_function_association = optional(list(object({ // A config block that triggers a lambda function with specific actions (maximum 4).
      event_type   = string,
      lambda_arn   = string,
      include_body = bool // When set to true it exposes the request body to the lambda function.
    })))
    use_aws_managed_cache_policy          = bool,
    cache_policy_name                     = string, // It can be custom or aws managed policy name , if custom cache_policies variable key should match
    use_aws_managed_origin_request_policy = optional(bool),
    origin_request_policy_name            = optional(string), // It can be custom or aws managed policy name , if custom origin_request_policies variable key should match
    compress                              = bool,
    viewer_protocol_policy                = string
  }))
  default = []
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

variable "cache_policies" {
  type = map(object(
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
  ))
  description = <<-EOT
      Cache policies,
		eg. {
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
    EOT

  default = {}
}

variable "origin_request_policies" {
  type = map(object({
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
  }))
  description = <<-EOT
      Origin request policies,
			eg. {
		"origin-req-policy" = {
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
    EOT
  default     = {}
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

variable "custom_error_responses" {
  type = list(object({
    error_caching_min_ttl = optional(number),
    error_code            = string,
    response_code         = optional(string),
    response_page_path    = optional(string) // eg:  /custom_404.html
  }))
  default     = []
  description = "One or more custom error response elements"
}

variable "price_class" {
  type        = string
  default     = "PriceClass_All"
  description = " Price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100."
}
