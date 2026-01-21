################################################################################
## Tags Module
################################################################################

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    RepoName = "terraform-aws-refarch-cloudfront"
  }
}

################################################################################
## S3 Buckets for Origins
################################################################################

module "primary_bucket" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.7"

  name = "${var.project_name}-primary-${random_id.bucket_suffix.hex}"
  acl  = "private"

  tags = module.tags.tags
}

module "secondary_bucket" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.7"

  providers = {
    aws = aws.dr
  }

  name = "${var.project_name}-secondary-${random_id.bucket_suffix.hex}"
  acl  = "private"

  tags = module.tags.tags
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

################################################################################
## Module Cloudfront with Origin Groups for DR
################################################################################

module "cloudfront" {
  source = "../../"

  providers = {
    aws.acm = aws.acm
  }

  origins = [
    {
      origin_type          = "s3"
      origin_id            = "primary-origin"
      domain_name          = module.primary_bucket.bucket_regional_domain_name
      bucket_name          = module.primary_bucket.bucket_id
      create_bucket        = false
      manage_bucket_policy = true
    },
    {
      origin_type          = "s3"
      origin_id            = "secondary-origin"
      domain_name          = module.secondary_bucket.bucket_regional_domain_name
      bucket_name          = module.secondary_bucket.bucket_id
      create_bucket        = false
      manage_bucket_policy = false
    }
  ]

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

  description            = "CloudFront distribution with origin group for DR"
  route53_root_domain    = var.route53_root_domain
  create_route53_records = var.create_route53_records
  aliases                = []

  default_cache_behavior = {
    origin_id                             = "failover-group"
    allowed_methods                       = ["GET", "HEAD", "OPTIONS"]
    cached_methods                        = ["GET", "HEAD"]
    compress                              = true
    viewer_protocol_policy                = "redirect-to-https"
    use_aws_managed_cache_policy          = true
    cache_policy_name                     = "CachingOptimized"
    use_aws_managed_origin_request_policy = true
    origin_request_policy_name            = "CORS-S3Origin"
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  tags = module.tags.tags
}


resource "aws_s3_bucket_policy" "dr_cdn_bucket_policy" {
  bucket = module.secondary_bucket.bucket_id

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
        Resource = "${module.secondary_bucket.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = module.cloudfront.cloudfront_arn
          }
        }
      }
    ]
  })

  provider = aws.dr
}
