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
