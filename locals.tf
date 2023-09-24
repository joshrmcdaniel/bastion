locals {
  resource_path = "${path.module}/provision"
  netmask       = split("/", var.wireguard_cidr)[1]
}
