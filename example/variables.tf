
# Define the required variables
variable "environment" {
  description = "The environment name"
  type        = string
}
variable "project_name" {
  description = "The project name"
  type        = string
}
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
variable "namespace" {
  description = "The namespace"
  type        = string
}
variable "sub_domain" {
  description = "The subdomain"
  type        = string
}
variable "domain" {
  description = "The domain name"
  type        = string
}
variable "custom_domains" {
  description = "List of custom domain names"
  type        = list(string)
}

variable "enable_route53" {
  description = "Whether to enable Route53 and ACM"
  type        = bool
  default     = false
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}
