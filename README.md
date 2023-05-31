# terraform-aws-refarch-cloudfront

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.18.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | git::https://github.com/cloudposse/terraform-aws-s3-bucket | 3.0.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | git::https://github.com/sourcefuse/terraform-aws-refarch-tags | 1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket_policy.cdn_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name. If provided, the bucket will be created with this name instead of generating the name from the context | `string` | `null` | no |
| <a name="input_cors_configuration"></a> [cors\_configuration](#input\_cors\_configuration) | Specifies the allowed headers, methods, origins and exposed headers when using CORS on this bucket | <pre>list(object({<br>    allowed_headers = list(string)<br>    allowed_methods = list(string)<br>    allowed_origins = list(string)<br>    expose_headers  = list(string)<br>    max_age_seconds = number<br>  }))</pre> | `null` | no |
| <a name="input_custom_domains"></a> [custom\_domains](#input\_custom\_domains) | Fully qualified domain name for site being hosted | `list(string)` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain to add to route 53 as alias to distribution | `string` | n/a | yes |
| <a name="input_dynamic_default_cache_behavior"></a> [dynamic\_default\_cache\_behavior](#input\_dynamic\_default\_cache\_behavior) | Set the cache behavior for the distribution here | <pre>list(object({<br>    allowed_methods        = list(string)<br>    cached_methods         = list(string)<br>    target_origin_id       = string<br>    compress               = bool<br>    viewer_protocol_policy = string<br>    min_ttl                = number<br>    default_ttl            = number<br>    max_ttl                = number<br>  }))</pre> | n/a | yes |
| <a name="input_enable_route53"></a> [enable\_route53](#input\_enable\_route53) | made optional route53 | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment resources belong to. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. | `string` | `"cloudfront-iac"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_sub_domain"></a> [sub\_domain](#input\_sub\_domain) | Fully qualified domain name for site being hosted | `string` | n/a | yes |
| <a name="input_website_configuration"></a> [website\_configuration](#input\_website\_configuration) | Specifies the static website hosting configuration object | <pre>list(object({<br>    index_document = string<br>    error_document = string<br>    routing_rules = list(object({<br>      condition = object({<br>        http_error_code_returned_equals = string<br>        key_prefix_equals               = string<br>      })<br>      redirect = object({<br>        host_name               = string<br>        http_redirect_code      = string<br>        protocol                = string<br>        replace_key_prefix_with = string<br>        replace_key_with        = string<br>      })<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_website_redirect_all_requests_to"></a> [website\_redirect\_all\_requests\_to](#input\_website\_redirect\_all\_requests\_to) | If provided, all website requests will be redirected to the specified host name and protocol | <pre>list(object({<br>    host_name = string<br>    protocol  = string<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
