variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "enable_logging" {
  type        = bool
  description = "Enable logging for Clouffront destribution, this will create new S3 bucket"
  default     = true
}

variable "create_route53_records" {
  type        = bool
  description = "made optional route53"
  default     = true
}
