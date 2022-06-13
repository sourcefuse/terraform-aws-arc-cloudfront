module "s3-cloudfront-site" {
  source                   = "../"
  certificate_arn          = var.certificate_arn
  environment              = var.environment
  FQDN                     = var.FQDN   
  responsible_party        = var.responsible_party
  versioning_enabled       = true
  zone_id                  = var.zone_id
}
