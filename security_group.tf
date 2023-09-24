resource "aws_security_group" "wg" {
  name        = "wireguard_inbound"
  description = "Wireguard inbound"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Bastion security group"
  }
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.wg.id
  description       = "Allow egress out"

  type      = "egress"
  from_port = var.wireguard_port
  to_port   = var.wireguard_port
  protocol  = "-1"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "wireguard" {
  security_group_id = aws_security_group.wg.id
  description       = "Allow wireguard in"

  type      = "ingress"
  from_port = var.wireguard_port
  to_port   = var.wireguard_port
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh" {
  count = var.ssh_enabled ? 1 : 0

  security_group_id = aws_security_group.wg.id
  description       = "Allow SSH in"

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]

}