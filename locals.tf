locals {
  resource_path = "${path.module}/provision"
  cidrs         = join(",", var.cidr_blocks)
}
