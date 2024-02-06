# Terraform AWS ARC Cloudfront Module Usage Guide

## Introduction

### Purpose of the Document

This document provides guidelines and instructions for users looking to implement Terraform module for managing Cloudfront, S3, Route53 and ACM

### Module Overview

The [terraform-aws-arc-cloudfront](https://github.com/sourcefuse/terraform-aws-arc-cloudfront) module provides a secure and modular foundation for managing Cloudfront, S3, Route53 and ACM

### Prerequisites

Before using this module, ensure you have the following:

- AWS credentials configured.
- Terraform installed.
- A working knowledge of AWS Cloudfront, Route53

## Getting Started

### Module Source

To use the module in your Terraform configuration, include the following source block:

```hcl
module "cloudfront" {
  source  = "sourcefuse/arc-cloudfront/aws"
  version = "4.0.3"
  # insert the required variables here
}
```

### Integration with Existing Terraform Configurations

Integrate the module with your existing Terraform mono repo configuration, follow the steps below:

1. Create a new folder in `terraform/` named `cloudfront`.
2. Create the required files, see the [examples](https://github.com/sourcefuse/terraform-aws-arc-cloudfront/tree/main/examples/simple) to base off of.
3. Configure with your backend
  - Create the environment backend configuration file: `config.<environment>.hcl`
    - **region**: Where the backend resides
    - **key**: `<working_directory>/terraform.tfstate`
    - **bucket**: Bucket name where the terraform state will reside
    - **dynamodb_table**: Lock table so there are not duplicate tfplans in the mix
    - **encrypt**: Encrypt all traffic to and from the backend

### Required AWS Permissions

Ensure that the AWS credentials used to execute Terraform have the necessary permissions to set up a CloudFront distribution.

## Module Configuration

### Input Variables

For a list of input variables, see the README [Inputs](https://github.com/sourcefuse/terraform-aws-arc-cloudfront?tab=readme-ov-file#inputs) section.

### Output Values

For a list of outputs, see the README [Outputs](https://github.com/sourcefuse/terraform-aws-arc-cloudfront?tab=readme-ov-file#outputs) section.

## Module Usage

### Basic Usage

For basic usage, see the [example](https://github.com/sourcefuse/terraform-aws-arc-cloudfront/tree/main/example) folder.

This example will create:

It creates the CloudFront distribution. It includes configurations for:

Origins: These are the places where CloudFront will fetch the content. In this case, it's a custom origin with the domain name "test.wpengine.com".

Cache behaviors: These define how CloudFront caches and serves content. There are two cache behaviors defined, one for the default cache behavior and one for the path "/content/immutable/*".

Viewer certificate: This is the SSL certificate that CloudFront will use to serve HTTPS requests. It's configured to use an ACM certificate.

ACM details: These are the details of the ACM certificate that CloudFront will use.

Cache policies: These define how CloudFront will cache content. There's one cache policy defined named "cache-policy-1".

Origin request policies: These define how CloudFront will forward requests to the origin. There's one origin request policy defined named "origin-req-policy-1".

Custom error responses: These define how CloudFront will respond when it encounters specific HTTP status codes. There's one custom error response defined for the 404 status code.

S3 KMS details: These are the details of the KMS key that will be used to encrypt the S3 bucket where CloudFront logs will be stored.

Response headers policy: This defines the response headers that CloudFront will include in its responses. There's one response headers policy defined named "test-security-headers-policy"

locals: This block defines local values that can be used throughout the Terraform script. In this case, it's defining the details of the "test-security-headers-policy" response headers policy.

### Tips and Recommendations

The module focuses on setting up setting up a AWS CloudFront distribution with various configurations. Adjust the configuration parameters as needed for your specific use case.

## Troubleshooting

### Reporting Issues

If you encounter a bug or issue, please report it on the [GitHub repository](https://github.com/sourcefuse/terraform-aws-arc-cloudfront/issues).

## Security Considerations

### AWS VPC

Understand the security considerations related to AWS CloudFront distribution when using this module.

### Best Practices for AWS CloudFront distribution

Follow best practices to ensure best Security configurations.
[CLoudFront Security on AWS](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/security.html)

## Contributing and Community Support

### Contributing Guidelines

Contribute to the module by following the guidelines outlined in the [CONTRIBUTING.md](https://github.com/sourcefuse/terraform-aws-arc-cloudfront/blob/main/CONTRIBUTING.md) file.

### Reporting Bugs and Issues

If you find a bug or issue, report it on the [GitHub repository](https://github.com/sourcefuse/terraform-aws-arc-cloudfront/issues).

## License

### License Information

This module is licensed under the Apache 2.0 license. Refer to the [LICENSE](https://github.com/sourcefuse/terraform-aws-arc-cloudfront/blob/main/LICENSE) file for more details.

### Open Source Contribution

Contribute to open source by using and enhancing this module. Your contributions are welcome!
