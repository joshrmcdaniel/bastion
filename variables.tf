variable "vpc_id" {
  description = "VPC ID to use for the EC2."
  type        = string
  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8}(?:[a-f0-9]{9})?$", var.vpc_id))
    error_message = "Invalid VPC ID provided."
  }
}

variable "ssh_enabled" {
  description = "Enable SSH on the machine."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "SSH key to access the EC2."
  type        = string
  default     = null
}

variable "wireguard_port" {
  description = "Ingress port for wireguard"
  type        = number
  default     = 51820
  validation {
    condition     = var.wireguard_port > 1024 && var.wireguard_port < 65536
    error_message = "Port value is invalid."
  }
}

variable "wireguard_cidr" {
  description = "CIDR for wireguard to use."
  type        = string
  default     = "172.27.3.0/29"

  validation {
    condition     = can(cidrnetmask(var.wireguard_cidr)) && can(regex("^((10\\.)|(172\\.(1[6-9]|2[0-9]|3[01]))|(192\\.168))", var.wireguard_cidr))
    error_message = "Invalid wireguard CIDR provided."
  }
}

variable "lan_cidrs" {
  description = "LAN CIDR blocks for wireguard to access."
  type        = list(string)
  validation {
    condition     = alltrue([for cidr in var.lan_cidrs : can(cidrnetmask(cidr)) && can(regex("^((10\\.)|(172\\.(1[6-9]|2[0-9]|3[01]))|(192\\.168))", cidr))])
    error_message = "An invalid CIDR was provided."
  }
}

variable "lan_pub_key" {
  description = "Wireguard public Key for the LAN host."
  type        = string
}

variable "wan_pub_key" {
  description = "Wireguard public key for the WAN host."
  type        = string
}
