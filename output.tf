output "ec2_ip" {
  description = "IP of EC2"
  value       = aws_eip.bastion.public_ip
}

output "pub_key_arn" {
  description = "ARN of the SSM parameter"
  value       = aws_ssm_parameter.wg_pubkey.arn
}