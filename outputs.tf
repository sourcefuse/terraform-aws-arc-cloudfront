output "s3_bucket" {
  value = {
    name = aws_s3_bucket.this.id
    arn  = aws_s3_bucket.this.arn
  }
  description = "Details of the S3 bucket created to host the site content"
}


output "cloudfront_distribution" {
  value = {
    id          = aws_cloudfront_distribution.distribution.id
    arn         = aws_cloudfront_distribution.distribution.arn
    domain_name = aws_cloudfront_distribution.distribution.domain_name
  }
  description = "Details about the CloudFront distribution created to serve the site content"
}
