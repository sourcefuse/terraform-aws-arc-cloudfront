resource "aws_kms_key" "this" {
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  policy                   = var.key_policy == null ? local.key_policy : var.key_policy
  description              = var.description
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  multi_region             = var.multi_region
  tags                     = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.environment}/${var.alias}" // eg alias/dev/s3
  target_key_id = aws_kms_key.this.key_id
}
