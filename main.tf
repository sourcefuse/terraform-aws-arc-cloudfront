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

  default_root_object = var.default_object
  enabled             = true
  aliases             = ["${var.sub_domain}.${var.domain}"]

  dynamic "default_cache_behavior" {
    for_each = var.dynamic_default_cache_behavior[*]
    iterator = i
    content {
      allowed_methods        = i.value.allowed_methods
      cached_methods         = i.value.cached_methods
      target_origin_id       = i.value.target_origin_id
      compress               = lookup(i.value, "compress", null)
      viewer_protocol_policy = i.value.viewer_protocol_policy
      min_ttl                = lookup(i.value, "min_ttl", null)
      default_ttl            = lookup(i.value, "default_ttl", null)
      max_ttl                = lookup(i.value, "max_ttl", null)

      # dynamic "forwarded_values" {
      #   for_each = lookup(i.value, "use_forwarded_values", true) ? [true] : []
      #   content {
      #     query_string = lookup(i.value, "query_string", null)
      #     headers      = lookup(i.value, "headers", null)

      #     cookies {
      #       forward = lookup(i.value, "cookies_forward", null)
      #     }
      #   }
      # }

    }

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
