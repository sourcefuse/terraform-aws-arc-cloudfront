variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "arc-cloudfront-dr"
}

variable "route53_root_domain" {
  description = "Route53 root domain"
  type        = string
  default     = "arc-poc.link"
}

variable "create_route53_records" {
  description = "Create Route53 records"
  type        = bool
  default     = false
}
