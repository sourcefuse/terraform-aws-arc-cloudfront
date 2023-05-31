##################################################################################
# Tags #
##################################################################################

module "tags" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags?ref=1.1.0"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    RepoName     = "cloudfront-iac"
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
  tags = module.tags.tags
}


resource "aws_s3_bucket_policy" "cdn_bucket_policy" {
  bucket = module.s3_bucket.bucket_id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${module.s3_bucket.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.website_distribution.arn
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
  for_each = var.dynamic_default_cache_behavior
  content {
    allowed_methods        = default_cache_behavior.value.allowed_methods
    cached_methods         = default_cache_behavior.value.cached_methods
    target_origin_id       = default_cache_behavior.value.target_origin_id
    compress               = lookup(default_cache_behavior.value, "compress", null)
    viewer_protocol_policy = default_cache_behavior.value.viewer_protocol_policy
    min_ttl                = lookup(default_cache_behavior.value, "min_ttl", null)
    default_ttl            = lookup(default_cache_behavior.value, "default_ttl", null)
    max_ttl                = lookup(default_cache_behavior.value, "max_ttl", null)

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }
}

  aliases = var.custom_domains

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    include_cookies = false
    bucket          = module.s3_bucket.bucket_name
    prefix          = var.project_name
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
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
data "aws_route53_zone" "zone" {
  count        = var.enable_route53 ? 1 : 0
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "record" {
  count        = var.enable_route53 ? 1 : 0
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
   // Associate the CDN's domain name or alias with the Route 53 record
  # records = [aws_cloudfront_distribution.distribution.domain_name]

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  count        = var.enable_route53 ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]

  depends_on = [aws_route53_record.record]
}
