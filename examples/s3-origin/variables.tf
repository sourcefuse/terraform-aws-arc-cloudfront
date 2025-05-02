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