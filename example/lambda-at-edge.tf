
/**
 * Create the Lambda function. Each new apply will publish a new version.
 */
# resource "aws_lambda_function" "lambda" {
#   function_name = var.name
#   description   = var.description

#   # Find the file from S3
#   s3_bucket         = var.s3_artifact_bucket
#   s3_key            = aws_s3_bucket_object.artifact.id
#   s3_object_version = aws_s3_bucket_object.artifact.version_id
#   source_code_hash  = filebase64sha256(data.archive_file.zip_file_for_lambda.output_path)

#   publish = true
#   handler = var.handler
#   runtime = var.runtime
#   role    = aws_iam_role.lambda_at_edge.arn
#   tags    = module.tags.tags

#   lifecycle {
#     ignore_changes = [
#       last_modified,
#     ]
#   }
# }

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/src/edge-function"
  output_path = "${path.module}/src/edge-function.zip"
}

resource "aws_lambda_function" "this" {
  source_code_hash = data.archive_file.this.output_base64sha256 // To redeploy the code its if its changed

  filename      = data.archive_file.this.output_path
  function_name = "test-edge-function"
  role          = aws_iam_role.lambda_at_edge.arn
  handler       = "edgeFunction.handler"
  runtime       = "nodejs14.x"
  architectures = ["x86_64"]
  description   = "This is a test Edge function"
  publish       = true

  provider = aws.lambda_at_edge
}

/**
 * Policy to allow AWS to access this lambda function.
 */
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AllowAwsToAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }
  }
}

/**
 * Make a role that AWS services can assume that gives them access to invoke our function.
 * This policy also has permissions to write logs to CloudWatch.
 */
resource "aws_iam_role" "lambda_at_edge" {
  name               = "edge-function-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = module.tags.tags
}

/**
 * Allow lambda to write logs.
 */
data "aws_iam_policy_document" "lambda_logs_policy_doc" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",

      # Lambda@Edge logs are logged into Log Groups in the region of the edge location
      # that executes the code. Because of this, we need to allow the lambda role to create
      # Log Groups in other regions
      "logs:CreateLogGroup",
    ]
  }
}

/**
 * Attach the policy giving log write access to the IAM Role
 */
resource "aws_iam_role_policy" "logs_role_policy" {
  name   = "edge-functionat-edge"
  role   = aws_iam_role.lambda_at_edge.id
  policy = data.aws_iam_policy_document.lambda_logs_policy_doc.json
}

/**
 * Creates a Cloudwatch log group for this function to log to.
 * With lambda@edge, only test runs will log to this group. All
 * logs in production will be logged to a log group in the region
 * of the CloudFront edge location handling the request.
 */
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/lambda/edge-function"
  tags = module.tags.tags
}

// Permission is important : The Lambda function associated with the CloudFront distribution is invalid or doesn't have the required permissions.
resource "aws_lambda_permission" "allow_cloudfront" {
  function_name = aws_lambda_function.this.function_name
  statement_id  = "AllowExecutionFromCloudFront"
  action        = "lambda:GetFunction"
  principal     = "edgelambda.amazonaws.com"
}
