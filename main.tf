resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.sub_domain}.${var.domain}"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.this.bucket_domain_name
    origin_id   = "${var.sub_domain}.${var.domain}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_root_object = "index.html"
  enabled             = true
  aliases             = ["${var.sub_domain}.${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.sub_domain}.${var.domain}"

    # Forward all query strings, cookies and headers
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      # type of restriction, blacklist, whitelist or none
      restriction_type = "none"
    }
  }
  # SSL certificate for the service.
  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
  tags = {
    Name        = "${var.sub_domain}-s3-website-cert-${var.environment}"
    Environment = var.environment
  }

  depends_on = [
    aws_s3_bucket.this
  ]
}
