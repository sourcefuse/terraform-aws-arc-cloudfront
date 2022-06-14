variable "certificate_arn" {
  description = "Amazon Resource Name (arn) for the site's certificate"
}

variable "sub_domain" {
  description = "Sub domain to add to route 53 as alias to distribution"
}

variable "domain" {
  description = "Domain to add to route 53 as alias to distribution"
}

variable "responsible_party" {
  description = "Person (pid) who is primarily responsible for the configuration and maintenance of this resource"
}

variable "environment" {
  description = "e.g. `development`, `test`, or `production`"
  default     = "dev"
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID to use for creation of records pointing to CloudFront distribution"
  default     = ""
}

variable "versioning_enabled" {
  description = "Versioning for the objects in the S3 bucket"
  default     = false
}
