locals {
  # concatenates the distint (differente) arns: terraform role, pre-defined kms administrators by environment, suplied arn given by the variable)
  kms_key_administrators = distinct(concat([
    data.aws_iam_session_context.current.issuer_arn
  ], var.kms_key_administrators))

  kms_key_users = distinct(concat([
    data.aws_iam_session_context.current.issuer_arn
  ], var.kms_key_users))

  key_policy = jsonencode({
    Id      = "key-policy-1",
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Allow access for Key Administrators",
        Effect = "Allow",
        Principal = {
          AWS = local.kms_key_administrators
        },
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key",
        Effect = "Allow",
        Principal = {
          AWS = local.kms_key_users
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow attachment of persistent resources",
        Effect = "Allow",
        Principal = {
          AWS = local.kms_key_users
        },
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Sid    = "Allow access to AWS services",
        Effect = "Allow",
        Principal = {
          Service = var.aws_services
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }

    ]
  })
}
