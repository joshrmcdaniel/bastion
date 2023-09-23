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
    cidrs                  = local.cidrs
    wan_wg_public_key      = var.wan_wg_public_key
    internal_wg_public_key = var.internal_wg_public_key
    wireguard_port         = var.wireguard_port
    pub_key_param          = aws_ssm_parameter.wg_pubkey
    ssh_enabled            = var.key_name != null
  }))

  lifecycle {
    precondition {
      condition     = fileexists("${local.resource_path}/deploy.sh")
      error_message = "User data file does not exist."
    }
    replace_triggered_by = [null_resource.wg_change]
  }
}

resource "null_resource" "wg_change" {
  triggers = {
    wan_pubkey = var.wan_wg_public_key
    lan_pubkey = var.internal_wg_public_key
    cidrs      = local.cidrs
  }
}
