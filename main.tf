data "aws_partition" "this" {}

data "aws_caller_identity" "this" {}

module "tags" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags?ref=1.1.0"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    RepoName = "cloudfront-iac"
  }
}

##################################################################################
# s3 Module #
##################################################################################

// Module creates KMS and its related resources
module "kms" {
  source                  = "./modules/kms"
  environment             = var.environment
  alias                   = "${var.environment}/s3/${var.bucket_name}"
  kms_key_administrators  = var.s3_kms_details.kms_key_administrators
  kms_key_users           = var.s3_kms_details.kms_key_users
  deletion_window_in_days = 7
  aws_services            = ["s3.amazonaws.com", "cloudfront.amazonaws.com"]
}

module "s3_bucket" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.0.0"

  bucket_name = "${var.environment}-${var.bucket_name}"
  environment = var.environment
  namespace   = var.namespace

  enabled            = true
  acl                = "private"
  versioning_enabled = true
  bucket_key_enabled = true
  kms_master_key_arn = module.kms.key_arn
  sse_algorithm      = "aws:kms"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:root"
        },
        Action = [
          "s3:GetObjectAttributes",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        Resource = "arn:${data.aws_partition.this.partition}:s3:::${var.namespace}-${terraform.workspace}-deployment/*"
      }
    ]
  })

  privileged_principal_actions = [
    "s3:GetObject",
    "s3:ListBucket",
    "s3:GetBucketLocation"
  ]
  cors_configuration = var.cors_configuration
  tags               = module.tags.tags
}

module "s3_bucket_logs" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.0.0"

  count = var.enable_logging ? 1 : 0

  bucket_name = "${var.environment}-${var.bucket_name}-logging"
  environment = var.environment
  namespace   = var.namespace

  acl                 = "private"
  s3_object_ownership = "BucketOwnerEnforced"
  user_enabled        = true
  versioning_enabled  = false
  bucket_key_enabled  = true
  kms_master_key_arn  = module.kms.key_arn
  sse_algorithm       = "aws:kms"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:root"
        },
        Action = [
          "s3:GetObjectAttributes",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        Resource = "arn:${data.aws_partition.this.partition}:s3:::${var.namespace}-${terraform.workspace}-deployment/*"
      }
    ]
  })

  privileged_principal_actions = [
    "s3:GetObject",
    "s3:ListBucket",
    "s3:GetBucketLocation"
  ]
  cors_configuration = var.cors_configuration
  tags               = module.tags.tags
}


resource "aws_cloudfront_cache_policy" "this" {
  name        = "${var.environment}-${module.s3_bucket.bucket_id}-cache-policy"
  comment     = "Cache policy"
  default_ttl = var.cache_policy.default_ttl
  max_ttl     = var.cache_policy.max_ttl
  min_ttl     = var.cache_policy.min_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = var.cache_policy.cookies_config.cookie_behavior
      cookies {
        items = var.cache_policy.cookies_config.items
      }
    }
    headers_config {
      header_behavior = var.cache_policy.cookies_config.cookie_behavior
      headers {
        items = var.cache_policy.cookies_config.items
      }
    }
    query_strings_config {
      query_string_behavior = var.cache_policy.query_strings_config.query_string_behavior
      query_strings {
        items = var.cache_policy.query_strings_config.items
      }
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "this" {
  name    = "${var.environment}-${module.s3_bucket.bucket_id}-origin-request-policy"
  comment = "Origin request policy"
  cookies_config {
    cookie_behavior = var.origin_request_policy.cookies_config.cookie_behavior
    cookies {
      items = var.origin_request_policy.cookies_config.items
    }
  }
  headers_config {
    header_behavior = var.origin_request_policy.headers_config.header_behavior
    headers {
      items = var.origin_request_policy.headers_config.items
    }
  }
  query_strings_config {
    query_string_behavior = var.origin_request_policy.query_strings_config.query_string_behavior
    query_strings {
      items = var.origin_request_policy.query_strings_config.items
    }
  }
}


resource "aws_s3_bucket_policy" "cdn_bucket_policy" {
  bucket = module.s3_bucket.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_bucket.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.distribution.arn
          }
        }
      }
    ]
  })
}

##################################################################################
# CDN #
##################################################################################

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.environment}-cf-origin-access-control"
  description                       = "Origin access control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name              = module.s3_bucket.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  comment             = var.description
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  dynamic "default_cache_behavior" {
    for_each = [var.default_cache_behavior]
    iterator = i

    content {
      allowed_methods        = i.value.allowed_methods
      cached_methods         = i.value.cached_methods
      target_origin_id       = local.origin_id
      compress               = lookup(i.value, "compress", false)
      viewer_protocol_policy = i.value.viewer_protocol_policy
      min_ttl                = lookup(i.value, "min_ttl", 0)
      default_ttl            = lookup(i.value, "default_ttl", 3600)
      max_ttl                = lookup(i.value, "max_ttl", 86400)

      cache_policy_id          = aws_cloudfront_cache_policy.this.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.this.id

    }
  }

  aliases = var.aliases

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []

    content {
      include_cookies = false
      bucket          = module.s3_bucket_logs[0].bucket_id
      prefix          = var.project_name
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.viewer_certificate.cloudfront_default_certificate ? null : aws_acm_certificate.this[0].arn
    cloudfront_default_certificate = var.viewer_certificate.cloudfront_default_certificate
    minimum_protocol_version       = var.viewer_certificate.minimum_protocol_version
    ssl_support_method             = var.viewer_certificate.ssl_support_method
  }

  depends_on = [aws_cloudfront_origin_access_control.this]
}

##################################################################################
# Route53 and ACM #
##################################################################################

resource "aws_acm_certificate" "this" {
  count             = var.enable_route53 ? 1 : 0
  domain_name       = var.acm_domain
  validation_method = "DNS"

  tags = module.tags.tags
}

// used to fetch route53 zone
data "aws_route53_zone" "this" {
  count        = var.enable_route53 ? 1 : 0
  name         = var.route53_domain
  private_zone = false
}

resource "aws_route53_record" "this" {
  for_each = var.enable_route53 ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this[0].zone_id
}


resource "aws_acm_certificate_validation" "this" {
  count                   = var.enable_route53 ? 1 : 0
  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]

  depends_on = [aws_route53_record.this]
}
