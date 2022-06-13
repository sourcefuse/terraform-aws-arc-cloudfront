
resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = var.FQDN
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
