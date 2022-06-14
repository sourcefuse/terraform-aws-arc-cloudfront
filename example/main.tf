module "s3_cloudfront_site" {
  source             = "../"
  certificate_arn    = var.certificate_arn
  environment        = var.environment
  sub_domain         = var.sub_domain
  domain             = var.domain
  responsible_party  = var.responsible_party
  versioning_enabled = true
  zone_id            = var.zone_id
}
