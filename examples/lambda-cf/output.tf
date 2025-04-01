output "origin_s3_bucket" {
  value       = module.cloudfront.origin_s3_bucket
  description = "Origin bucket name"
}

output "logging_s3_bucket" {
  value       = var.enable_logging ? module.cloudfront.logging_s3_bucket : null
  description = "Logging bucket name"
}

output "cloudfront_id" {
  value       = module.cloudfront.cloudfront_id
  description = "CloudFront ID"
}

output "cloudfront_arn" {
  value       = module.cloudfront.cloudfront_arn
  description = "CloudFront ARN"
}

output "cloudfront_domain_name" {
  value       = module.cloudfront.cloudfront_domain_name
  description = "CloudFront Domain name"
}

output "cloudfront_hosted_zone_id" {
  value       = module.cloudfront.cloudfront_hosted_zone_id
  description = "CloudFront Hosted zone ID"
}

output "acm_certificate_arn" {
  value       = var.create_route53_records ? module.cloudfront.acm_certificate_arn : null
  description = "Certificate ARN"
}
