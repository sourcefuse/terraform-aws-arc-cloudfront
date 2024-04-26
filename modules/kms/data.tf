# This data will return on something like arn:aws:sts::XXX:assumed-role/YYY"
data "aws_caller_identity" "current" {}

# Then we need this data to get the real IAM role arn, something like arn:aws:iam::XXX:role/YYY
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}
