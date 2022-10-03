variable "certificate_arn" {
  description = "Amazon Resource Name (arn) for the site's certificate"
  type        = string
}

variable "sub_domain" {
  description = "Fully qualified domain name for site being hosted"
  type        = string
}

# variable "responsible_party" {
#   description = "Person (pid) who is primarily responsible for the configuration and maintenance of this resource"
#   type        = string
# }

variable "environment" {
  description = "e.g. `development`, `test`, or `production`"
  type        = string
}

variable "default_object" {
  description = "Home page being served from S3 bucket"
  type        = string
}

variable "default_error_object" {
  description = "Error page being served from S3 bucket"
  type        = string
}


variable "zone_id" {
  description = "Route53 Hosted Zone ID to use for creation of records pointing to CloudFront distribution"
  type        = string
}

variable "versioning_enabled" {
  description = "Versioning for the objects in the S3 bucket"
  type        = bool
  default     = false
}


variable "domain" {
  description = "Domain to add to route 53 as alias to distribution"
  type        = string
}


variable "dynamic_default_cache_behavior" {
  description = "Set the cache behavior for distrubution here"
  type        = list(any)
}
