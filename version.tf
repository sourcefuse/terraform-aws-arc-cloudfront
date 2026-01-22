terraform {
  required_version = ">= 1.5, < 2.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 6.5.0, < 7.0.0"
      configuration_aliases = [aws.acm] // Currently we cannot make it as optional : https://github.com/hashicorp/terraform/issues/30461
    }
  }
}
