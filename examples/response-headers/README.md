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
