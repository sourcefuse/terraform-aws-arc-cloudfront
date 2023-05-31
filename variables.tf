variable "profile" {
  description = "your aws profile"
  type        = string
}

variable "sub_domain" {
  description = "Fully qualified domain name for site being hosted"
  type        = string
}

variable "custom_domains" {
  description = "Fully qualified domain name for site being hosted"
  type        = list(string)
}

variable "domain" {
  description = "Domain to add to route 53 as alias to distribution"
  type        = string
}

variable "dynamic_default_cache_behavior" {
  description = "Set the cache behavior for the distribution here"
  type        = list(object({
    allowed_methods        = list(string)
    cached_methods         = list(string)
    target_origin_id       = string
    compress               = bool
    viewer_protocol_policy = string
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number
  }))
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
  type    = bool
  description = "made optional route53"
  default  = false
}

