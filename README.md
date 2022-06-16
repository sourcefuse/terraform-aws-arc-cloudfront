# terraform-aws-refarch-cloudfront

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.18.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_object.object-upload-html](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Amazon Resource Name (arn) for the site's certificate | `string` | `"arn"` | no |
| <a name="input_default_error_object"></a> [default\_error\_object](#input\_default\_error\_object) | Error page being served from S3 bucket | `string` | `"error.html"` | no |
| <a name="input_default_object"></a> [default\_object](#input\_default\_object) | Home page being served from S3 bucket | `string` | `"index.html"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain to add to route 53 as alias to distribution | `string` | `"mydomain.com"` | no |
| <a name="input_dynamic_default_cache_behavior"></a> [dynamic\_default\_cache\_behavior](#input\_dynamic\_default\_cache\_behavior) | Set the cache behavior for distrubution here | `list(any)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | e.g. `development`, `test`, or `production` | `string` | `"dev"` | no |
| <a name="input_responsible_party"></a> [responsible\_party](#input\_responsible\_party) | Person (pid) who is primarily responsible for the configuration and maintenance of this resource | `string` | `"person1"` | no |
| <a name="input_sub_domain"></a> [sub\_domain](#input\_sub\_domain) | Fully qualified domain name for site being hosted | `string` | `"my-sub-domain"` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Versioning for the objects in the S3 bucket | `bool` | `false` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 Hosted Zone ID to use for creation of records pointing to CloudFront distribution | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution"></a> [cloudfront\_distribution](#output\_cloudfront\_distribution) | Details about the CloudFront distribution created to serve the site content |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | Details of the S3 bucket created to host the site content |
<!-- END_TF_DOCS -->
