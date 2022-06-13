variable "certificate_arn" {
  description = "Amazon Resource Name (arn) for the site's certificate"
}

variable "FQDN" {
  description = "Fully qualified domain name for site being hosted"
}

variable "responsible_party" {
  description = "Person (pid) who is primarily responsible for the configuration and maintenance of this resource"
}

variable "environment" {
  description = "e.g. `development`, `test`, or `production`"
  default     = "dev"
}

variable "error_document" {
  description = "Error page being served from S3 bucket"
  default     = "error.html"
}

variable "index_document" {
  description = "Home page being served from S3 bucket"
  default     = "index.html"
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID to use for creation of records pointing to CloudFront distribution"
  default     = ""
}

variable "versioning_enabled" {
  description = "Versioning for the objects in the S3 bucket"
  default     = false
}
