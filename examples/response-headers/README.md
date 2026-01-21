# CloudFront Response Headers Policy Example

This example demonstrates how to configure CloudFront with custom response headers policies for enhanced security and CORS handling.

## Features

- **Security Headers**: Content Security Policy, X-Frame-Options, X-Content-Type-Options, etc.
- **CORS Configuration**: Cross-Origin Resource Sharing headers
- **Custom Headers**: Add custom headers to responses
- **S3 Origin**: Uses S3 bucket as origin

## Response Headers Policy Configuration

The example includes:

### Security Headers
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- `Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'`

### CORS Headers
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, HEAD, OPTIONS`
- `Access-Control-Allow-Headers: *`
- `Access-Control-Expose-Headers: ETag`
- `Access-Control-Max-Age: 86400`

### Custom Headers
- `X-Custom-Header: CustomValue`

## Usage

```bash
terraform init
terraform plan
terraform apply
```

The distribution will automatically add the configured response headers to all responses from the origin.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | ENV for the resource | `string` | `"dev"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | Certificate ARN |
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | CloudFront Domain name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->