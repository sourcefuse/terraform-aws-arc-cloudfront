locals {
  environment = var.tags["Environment"]
  // Remove domains starting with *, eg. *.test.com
  aliases = [for alias in var.aliases : alias if length(regexall("[*]+", alias)) == 0]
}
