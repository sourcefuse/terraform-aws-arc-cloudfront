
##################################################################################
# s3 #
##################################################################################

resource "aws_s3_bucket" "docs_bucket" {
  bucket = "your-bucket-name"  # Update with your desired bucket name
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.logging_bucket.id  # Update with your desired logging bucket name
    target_prefix = "logs/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    Name        = "${var.sub_domain}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket = "your-logging-bucket-name"  # Update with your desired logging bucket name
  acl    = "private"

  lifecycle {
    prevent_destroy = true  # To prevent accidental deletion of logs
  }
}

resource "aws_s3_bucket_policy" "docs_bucket_policy" {
  bucket = aws_s3_bucket.docs_bucket.id

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
        Resource  = "${aws_s3_bucket.docs_bucket.arn}/*"
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

  depends_on = [aws_s3_bucket.docs_bucket]
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
  domain_name = aws_s3_bucket.docs_bucket.bucket_regional_domain_name
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

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [aws_cloudfront_origin_access_identity.origin_access_identity,
    aws_route53_record.record,
    aws_acm_certificate_validation.validation
    ]
}

##################################################################################
# Route53 and ACM #
##################################################################################

resource "aws_acm_certificate" "cert" {
  domain_name       = "example.com"
  validation_method = "DNS"
}

// used to fetch route53 zone
data "aws_route53_zone" "zone" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
   // Associate the CDN's domain name or alias with the Route 53 record
  records = [aws_cloudfront_distribution.distribution.domain_name]

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]

  depends_on = [aws_route53_record.record]
}
