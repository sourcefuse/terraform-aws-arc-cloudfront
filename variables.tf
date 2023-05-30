# variable "certificate_arn" {
#   description = "Amazon Resource Name (arn) for the site's certificate"
#   type        = string
# }

# variable "sub_domain" {
#   description = "Fully qualified domain name for site being hosted"
#   type        = string
# }

# variable "environment" {
#   description = "e.g. `development`, `test`, or `production`"
#   type        = string
# }

# variable "default_object" {
#   description = "Home page being served from S3 bucket"
#   type        = string
# }

# variable "default_error_object" {
#   description = "Error page being served from S3 bucket"
#   type        = string
# }


# variable "zone_id" {
#   description = "Route53 Hosted Zone ID to use for creation of records pointing to CloudFront distribution"
#   type        = string
# }


# variable "domain" {
#   description = "Domain to add to route 53 as alias to distribution"
#   type        = string
# }


# variable "dynamic_default_cache_behavior" {
#   description = "Set the cache behavior for distrubution here"
#   type        = list(any)
# }

# variable "waf_web_acl" {
#   description = "Cloudfront rate based statement"
#   type        = string
#   default     = "rate-based-example"
# }

# variable "rules" {
#   type    = string
#   default = "First Rule"
# }

# variable "bucket_versioning_enabled" {
#   type    = bool
#   default = true
# }

# variable "bucket_versioning_mfa_delete" {
#   type    = bool
#   default = true
# }


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

// need to add more variables from the code