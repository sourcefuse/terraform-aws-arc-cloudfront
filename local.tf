locals {
  origin_id   = "${var.tags["Environment"]}-${var.bucket_name}"
  environment = var.tags["Environment"]
}
