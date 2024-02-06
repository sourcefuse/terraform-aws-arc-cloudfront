locals {
  #environment = var.tags["Environment"]
  environment = lookup(var.tags, "Environment", "default")
  // Remove domains starting with *, eg. *.test.com
  aliases = [for alias in var.aliases : alias if length(regexall("[*]+", alias)) == 0]
}
