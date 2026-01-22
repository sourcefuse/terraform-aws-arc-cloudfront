variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "create_route53_records" {
  type        = bool
  description = "made optional route53"
  default     = true
}
