## IAM user for each site
#resource "aws_iam_user" "iam" {
#  name = var.ci_username
 # tags = local.service_tags
#}

#resource "aws_iam_user_policy" "iam_inline_policy" {
#   name        = "${var.ci_username}-policy"
#   user        = aws_iam_user.iam.name
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "ListS3buckets",
#             "Effect": "Allow",
#             "Action": [
#                 "s3:ListBucket"
#             ],
#             "Resource": [
#                 "${aws_s3_bucket.S3.arn}"
#             ]
#         },
#         {
#             "Sid": "BucketObjectAccess",
#             "Effect": "Allow",
#             "Action": [
#                 "s3:PutObject",
#                 "s3:DeleteObject",
#                 "s3:GetObject",
#                 "s3:ListMultipartUploadParts"
#             ],
#             "Resource": [
#                 "${aws_s3_bucket.S3.arn}/*"
#             ]
#         },
#         {
#             "Sid": "DistributionInvalidation",
#             "Effect": "Allow",
#             "Action": [
#                 "cloudfront:CreateInvalidation"
#             ],
#             "Resource": [
#                 "${aws_cloudfront_distribution.distribution.arn}"
#             ]   
#         }
#     ]
# }
# EOF
# }