output "ec2_ip" {
  description = "IP of EC2"
  value       = aws_eip.bastion.public_ip
}