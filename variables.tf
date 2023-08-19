variable "key_name" {
  description = "SSH key to access the EC2."
  type        = string
  default     = null
}

variable "home_cidr" {
  description = "CIDR block of home network."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.home_cidr))
    error_message = "Invalid CIDR provided."
  }
}

variable "wireguard_port" {
  description = "Ingress port for wireguard"
  type        = number
  default     = 38205
  validation {
    condition     = var.wireguard_port > 1024 && var.wireguard_port < 65536
    error_message = "Port value is invalid."
  }
}

variable "vpc_id" {
  description = "VPC ID to use for the EC2."
  type        = string
}

variable "wan_wg_public_key" {
  description = "Wireguard public Key for the external facing host."
  type        = string
}

variable "internal_wg_public_key" {
  description = "Wireguard public Key for the internal facing host."
  type        = string
}