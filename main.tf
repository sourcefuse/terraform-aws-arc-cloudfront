################################################################################
## account
################################################################################
data "aws_partition" "this" {}

################################################################################
## network
################################################################################
data "aws_caller_identity" "this" {}


##################################################################################
# Tags #
##################################################################################

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

module "s3_bucket" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.0.0"

  bucket_name = var.bucket_name
  environment = var.environment
  namespace   = var.namespace

  enabled            = true
  user_enabled       = false
  versioning_enabled = true
  bucket_key_enabled = true
  kms_master_key_arn = "arn:${data.aws_partition.this.partition}:kms:${var.region}:${data.aws_caller_identity.this.account_id}:alias/aws/s3"
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
  website_configuration            = var.website_configuration
  cors_configuration               = var.cors_configuration
  website_redirect_all_requests_to = var.website_redirect_all_requests_to
  tags                             = module.tags.tags
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

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access identity for S3 origin"

  depends_on = [module.s3_bucket]
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = module.s3_bucket.bucket_regional_domain_name
    origin_id   = "${var.sub_domain}.${var.domain}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  dynamic "default_cache_behavior" {
    for_each = var.default_cache_behavior
    iterator = i

    content {
      allowed_methods        = i.value.allowed_methods
      cached_methods         = i.value.cached_methods
      target_origin_id       = i.value.target_origin_id
      compress               = lookup(i.value, "compress", false)
      viewer_protocol_policy = i.value.viewer_protocol_policy
      min_ttl                = lookup(i.value, "min_ttl", 0)
      default_ttl            = lookup(i.value, "default_ttl", 3600)
      max_ttl                = lookup(i.value, "max_ttl", 86400)

      cache_policy_id          = aws_cloudfront_cache_policy.this.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.this.id

    }
  }

  aliases = var.custom_domains

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  logging_config {
    include_cookies = false
    bucket          = var.bucket_name
    prefix          = var.project_name
  }

  viewer_certificate {
    acm_certificate_arn            = var.viewer_certificate.cloudfront_default_certificate ? null : aws_acm_certificate.cert[0].arn
    cloudfront_default_certificate = var.viewer_certificate.cloudfront_default_certificate
    minimum_protocol_version       = var.viewer_certificate.minimum_protocol_version
    ssl_support_method             = var.viewer_certificate.ssl_support_method
  }

  depends_on = [aws_cloudfront_origin_access_identity.origin_access_identity]
}

##################################################################################
# Route53 and ACM #
##################################################################################

resource "aws_acm_certificate" "cert" {
  count             = var.enable_route53 ? 1 : 0
  domain_name       = var.domain
  validation_method = "DNS"

  tags = module.tags.tags
}

// used to fetch route53 zone
data "aws_route53_zone" "this" {
  count        = var.enable_route53 ? 1 : 0
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "this" {

  for_each = var.enable_route53 ? aws_acm_certificate.cert[0].domain_validation_options : []
  name     = each.value.resource_record_name
  records  = each.value.resource_record_value
  type     = each.value.resource_record_type

  allow_overwrite = true
  ttl             = 60

  zone_id = data.aws_route53_zone.this[0].zone_id
}


resource "aws_acm_certificate_validation" "this" {
  count                   = var.enable_route53 ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]

  depends_on = [aws_route53_record.this]
}
