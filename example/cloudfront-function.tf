resource "aws_cloudfront_function" "this" {
  name    = "Test-Cloudfront-Function"
  runtime = "cloudfront-js-1.0"
  comment = "CloudFront function"
  publish = true
  code    = file("${path.module}/src/cloudfront-function/cloudfrontFunction.js")
}
