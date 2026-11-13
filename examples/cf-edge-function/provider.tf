terraform {
  required_version = ">= 1.5, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.5.0, < 7.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  region = "us-east-1"
  alias  = "lambda_at_edge"
}

provider "aws" {
  region = "us-east-1"
  alias  = "acm"
}
