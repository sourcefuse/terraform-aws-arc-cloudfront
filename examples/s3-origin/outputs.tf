output "cloudfront_domain_name" {
  value       = module.cloudfront.cloudfront_domain_name
  description = "CloudFront Domain name"
}

output "acm_certificate_arn" {
  value       = module.cloudfront.acm_certificate_arn
  description = "Certificate ARN"
}
