<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | sourcefuse/arc-cloudfront/aws | 4.1.3 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_distribution_data"></a> [distribution\_data](#input\_distribution\_data) | A list of CloudFront distribution configurations. | <pre>list(<br>    object({<br>      id = string<br>      origins = list(<br>        object({<br>          origin_type   = string<br>          origin_id     = string<br>          domain_name   = string<br>          bucket_name   = string<br>          create_bucket = bool<br>        })<br>      )<br>      namespace              = string<br>      description            = string<br>      default_root_object    = string<br>      route53_root_domain    = string<br>      create_route53_records = bool<br>      aliases                = list(string)<br>      enable_logging         = bool<br>      default_cache_behavior = object({<br>        origin_id                               = string<br>        allowed_methods                         = list(string)<br>        cached_methods                          = list(string)<br>        compress                                = bool<br>        viewer_protocol_policy                  = string<br>        use_aws_managed_cache_policy            = bool<br>        cache_policy_name                       = string<br>        use_aws_managed_origin_request_policy   = bool<br>        origin_request_policy_name              = string<br>        use_aws_managed_response_headers_policy = bool<br>        response_headers_policy_name            = string<br>      })<br>      viewer_certificate = object({<br>        cloudfront_default_certificate = bool<br>        minimum_protocol_version       = string<br>        ssl_support_method             = string<br>      })<br>      acm_details = object({<br>        domain_name               = string<br>        subject_alternative_names = list(string)<br>      })<br>      custom_error_responses = list(<br>        object({<br>          error_caching_min_ttl = number<br>          error_code            = string<br>          response_code         = string<br>          response_page_path    = string<br>        })<br>      )<br>      price_class = string<br><br>    })<br>  )</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | ENV for the resource | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace in which we're working | `string` | `"arc"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->