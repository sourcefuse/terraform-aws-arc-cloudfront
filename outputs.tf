output "origin_s3_bucket" {
  value       = var.create_bucket ? module.s3_bucket[0].bucket_id : data.aws_s3_bucket.origin[0].id
  description = "Origin bucket name"
}

output "logging_s3_bucket" {
  value       = var.enable_logging ? module.s3_bucket_logs[0].bucket_id : null
  description = "Logging bucket name"
}

output "cloudfront_id" {
  value       = aws_cloudfront_distribution.this.id
  description = "CloudFront ID"
}

output "cloudfront_arn" {
  value       = aws_cloudfront_distribution.this.arn
  description = "CloudFront ARN"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "CloudFront Domain name"
}

output "cloudfront_hosted_zone_id" {
  value       = aws_cloudfront_distribution.this.hosted_zone_id
  description = "CloudFront Hosted zone ID"
}

output "acm_certificate_arn" {
  value       = var.create_route53_records ? aws_acm_certificate.this[0].arn : null
  description = "Certificate ARN"
}
