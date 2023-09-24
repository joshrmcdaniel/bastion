resource "aws_instance" "this" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.debian_12.id

  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids = [aws_security_group.wg.id]

  key_name = var.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    "Name"    = "bastion"
    "Service" = "Wireguard"
  }

  user_data_base64 = base64gzip(templatefile("${local.resource_path}/cloud-config.yaml", {
    wireguard_cidr = "${cidrhost(var.wireguard_cidr, 1)}/${local.netmask}"
    wan_peer       = "${cidrhost(var.wireguard_cidr, 4)}/32"
    lan_peer       = "${cidrhost(var.wireguard_cidr, 3)}/32"

    lan_cidrs = var.lan_cidrs

    wan_wg_public_key      = var.wan_pub_key
    internal_wg_public_key = var.lan_pub_key
    wireguard_port         = var.wireguard_port

    pub_key_param = aws_ssm_parameter.wg_pubkey
  }))

  lifecycle {
    precondition {
      condition     = var.ssh_enabled && var.key_name != null
      error_message = "SSH enabled but no key was provided."
    }

    replace_triggered_by = [null_resource.wg_change]
  }
}

resource "null_resource" "wg_change" {
  triggers = {
    wan_pubkey = var.wan_pub_key
    lan_pubkey = var.lan_pub_key
    lan_cidrs  = join(",", var.lan_cidrs)
    wg_cidrs   = var.wireguard_cidr
  }
}
