resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.bastion.id
}

resource "aws_eip" "bastion" {}
