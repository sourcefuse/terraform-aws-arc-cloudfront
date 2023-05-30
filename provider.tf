terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
