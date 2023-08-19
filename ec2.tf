resource "aws_instance" "this" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.debian_12.id
  user_data = templatefile("${local.resource_path}/deploy.sh", {
    home_cidr              = var.home_cidr
    wan_wg_public_key      = var.wan_wg_public_key
    internal_wg_public_key = var.internal_wg_public_key
    wireguard_port         = var.wireguard_port
  })
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.wg.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    "Name"      = "bastion"
    "Terraform" = true
    "Service"   = "Wireguard"
    "Purpose"   = "Bastion"
  }

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
    ec2 = join(",", [var.home_cidr, var.wan_wg_public_key, var.internal_wg_public_key])
  }
}