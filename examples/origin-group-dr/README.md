# CloudFront Origin Group for Disaster Recovery

This example demonstrates how to configure CloudFront with origin groups for disaster recovery scenarios.

## Features

- **Primary and Secondary Origins**: Configure multiple origins for failover
- **Automatic Failover**: CloudFront automatically routes traffic to secondary origin when primary fails
- **Configurable Status Codes**: Define which HTTP status codes trigger failover
- **High Availability**: Ensures continuous service availability during outages

## Usage

```hcl
origin_groups = [
  {
    origin_id = "failover-group"
    failover_criteria = {
      status_codes = [403, 404, 500, 502, 503, 504]
    }
    members = [
      {
        origin_id = "primary-origin"
      },
      {
        origin_id = "secondary-origin"
      }
    ]
  }
]
```

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

The distribution will automatically failover to the secondary origin when the primary returns any of the configured status codes.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.dr"></a> [aws.dr](#provider\_aws.dr) | 6.20.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ../../ | n/a |
| <a name="module_primary_bucket"></a> [primary\_bucket](#module\_primary\_bucket) | sourcefuse/arc-s3/aws | 0.0.7 |
| <a name="module_secondary_bucket"></a> [secondary\_bucket](#module\_secondary\_bucket) | sourcefuse/arc-s3/aws | 0.0.7 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_policy.dr_cdn_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_route53_records"></a> [create\_route53\_records](#input\_create\_route53\_records) | Create Route53 records | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | `"arc-cloudfront-dr"` | no |
| <a name="input_route53_root_domain"></a> [route53\_root\_domain](#input\_route53\_root\_domain) | Route53 root domain | `string` | `"arc-poc.link"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | CloudFront domain name |
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | CloudFront distribution ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->