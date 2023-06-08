locals {
  origin_id   = "${var.tags["Environment"]}-${var.bucket_name}"
  environment = var.tags["Environment"]
  aliases = {
    for alias in var.aliases : alias => alias
    if length(regexall("[*]+", alias)) == 0
  }
}
