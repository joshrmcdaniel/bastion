resource "aws_instance" "this" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.debian_12.id
  user_data     = templatefile("${local.resource_path}/deploy.sh", { home_cidr = var.home_cidr })

  lifecycle {
    precondition {
      condition     = fileexists("${local.resource_path}/deploy.sh")
      error_message = "User data file does not exist."
    }
  }
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
}

