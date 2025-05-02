# output "cloudfront_domain_name" {
#   value       = module.cloudfront.cloudfront_domain_name
#   description = "CloudFront Domain name"
# }

output "cloudfront_domain_names" {
  value = {
    for key, mod in module.cloudfront :
    key => mod.cloudfront_domain_name
  }
  description = "CloudFront Domain names from all distributions"
}