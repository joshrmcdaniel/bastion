data "aws_ami" "debian_12" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-12-amd64-20230910-1499"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["136693071363"]
}
