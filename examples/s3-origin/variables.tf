variable "project_name" {
  type        = string
  description = "Name of the project."
  default     = "arc"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "ENV for the resource"
  default     = "dev"
}

variable "namespace" {
  description = "Namespace in which we're working"
  type        = string
  default     = "arc"
}


variable "distribution_data" {
  description = "A list of CloudFront distribution configurations."
  type = list(
    object({
      id = string
      origins = list(
        object({
          origin_type   = string
          origin_id     = string
          domain_name   = string
          bucket_name   = string
          create_bucket = bool
        })
      )
      namespace              = string
      description            = string
      default_root_object    = string
      route53_root_domain    = string
      create_route53_records = bool
      aliases                = list(string)
      enable_logging         = bool
      default_cache_behavior = object({
        origin_id                               = string
        allowed_methods                         = list(string)
        cached_methods                          = list(string)
        compress                                = bool
        viewer_protocol_policy                  = string
        use_aws_managed_cache_policy            = bool
        cache_policy_name                       = string
        use_aws_managed_origin_request_policy   = bool
        origin_request_policy_name              = string
        use_aws_managed_response_headers_policy = bool
        response_headers_policy_name            = string
      })
      viewer_certificate = object({
        cloudfront_default_certificate = bool
        minimum_protocol_version       = string
        ssl_support_method             = string
      })
      acm_details = object({
        domain_name               = string
        subject_alternative_names = list(string)
      })
      custom_error_responses = list(
        object({
          error_caching_min_ttl = number
          error_code            = string
          response_code         = string
          response_page_path    = string
        })
      )
      price_class = string

    })
  )
}