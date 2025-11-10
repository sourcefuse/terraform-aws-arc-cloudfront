terraform {
  required_version = ">= 1.5, < 2.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0, < 6.0"
      configuration_aliases = [aws.acm] // Curremtly we cannot make it as optional : https://github.com/hashicorp/terraform/issues/30461
    }
  }
}
