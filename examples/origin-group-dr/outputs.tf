output "cloudfront_id" {
  value       = module.cloudfront.cloudfront_id
  description = "CloudFront distribution ID"
}

output "cloudfront_domain_name" {
  value       = module.cloudfront.cloudfront_domain_name
  description = "CloudFront domain name"
}
