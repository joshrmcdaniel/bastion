resource "aws_ssm_parameter" "wg_pubkey" {
  name  = "/bastion/wg.pub"
  type  = "SecureString"
  value = "CHANGES"
  lifecycle {
    ignore_changes = [value]
  }
}
