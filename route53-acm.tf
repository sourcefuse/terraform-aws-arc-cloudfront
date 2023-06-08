
##################################################################################
# Route53 and ACM #
##################################################################################

resource "aws_acm_certificate" "this" {
  count                     = var.acm_details.domain_name == "" ? 0 : 1
  domain_name               = var.acm_details.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.acm_details.subject_alternative_names

  tags = var.tags
}

// used to fetch route53 zone
data "aws_route53_zone" "this" {
  count        = var.create_route53_records ? 1 : 0
  name         = var.route53_root_domain
  private_zone = false
}

# Create CNAME for validating ACM certificate
resource "aws_route53_record" "this" {
  for_each = var.create_route53_records ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.route53_record_ttl
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this[0].zone_id
}


resource "aws_acm_certificate_validation" "this" {
  count                   = var.acm_details.domain_name == "" ? 0 : 1
  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]

  depends_on = [aws_route53_record.this]
}

// Create route53 record for domains in Cloudfront aliases
resource "aws_route53_record" "root_domain" {
  count   = var.create_route53_records ? length(local.aliases) : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = local.aliases[count.index]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
