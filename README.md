# Wireguard bastion module
Terraform module for deploying a wireguard instance in AWS configured for a home network.
The wireguard public/private keys of the bastion are generated on the instance, and the public key is stored in AWS parameter store under `/bastion/wg.pub`

## Wireguard network configuration
The address of the bastion will always be the first IP of `wireguard_cidr`. The LAN's wireguard address will be the 3rd IP in the block, and the WAN's wireguard address will be the 4th.

Example for `172.16.1.0/24`
- Bastion: `172.16.1.1`
- LAN: `172.16.1.3`
- WAN: `172.16.1.4`

## Usage

```hcl2
module "bastion" {
  source         = "git::github.com/joshrmcdaniel/bastion?ref=master"
  vpc_id         = "vpc-abcdef78"
  ssh_enabled    = true
  wireguard_port = 51820
  key_name       = "bastion_ssh_key"
  wireguard_cidr = "172.16.1.0/24"
  lan_cidrs      = ["10.0.0.0/8"]
  wan_pub_key    = "wan_wg_public_key" # Key from external wireguard client
  lan_pub_key    = "lan_wg_public_key" # Key from internal wireguard client
}
```

## Example WG configuration
- Wireguard network is `172.16.1.0/24`
- Wireguard listening port is `51820`
- Internal network is `10.0.0.0/8`
- `BASTION_PUB_KEY` is the parameter `/bastion/wg.pub`
- `WAN_HOST_PUB_KEY` is the `wan_pub_key` input
- `INTERNAL_HOST_PUB_KEY` is the `lan_pub_key` input

### Bastion
```ini
[Interface]
PrivateKey = BASTION_PRIVATE_KEY
PostUp = /etc/wireguard/postup.sh "%i"
PostDown = /etc/wireguard/postdown.sh "%i"
Address = 172.16.1.1/29
ListenPort = 51820
[Peer]
# WAN host
PublicKey = WAN_HOST_PUB_KEY
AllowedIPs = 172.16.1.4/32
[Peer]
# Internal host
PublicKey = INTERNAL_HOST_PUB_KEY
AllowedIPs = 172.16.1.3/32,10.0.0.0/8
```
### Internal host
```ini
[Interface]
PrivateKey = INTERNAL_HOST_PRIVATE_KEY
Address = 172.16.1.3/32
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostUp = iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -d 10.0.0.0/8 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s 172.16.1.0/24 -d 10.0.0.0/8 -j MASQUERADE
[Peer]
# Bastion
PublicKey = BASTION_PUB_KEY
Endpoint = EC2_IP:51820
AllowedIPs = 172.16.1.1/32
PersistentKeepalive = 5 # Required if host is behind NAT
[Peer]
# WAN host
PublicKey = WAN_HOST_PUB_KEY
AllowedIPs = 172.16.1.4/32
```

## WAN host
```ini
[Interface]
PrivateKey = WAN_HOST_PRIVATE_KEY
Address = 172.16.1.4/32
DNS = 10.0.0.1 # Optional, match it to the LAN DNS
[Peer]
# Bastion
PublicKey = BASTION_PUB_KEY
Endpoint = EC2_IP:51820
AllowedIPs = 10.0.0.0/8
```

# Terraform docs
<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.wg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.wg_pubkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [null_resource.wg_change](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_ami.debian_12](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.bastion_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.bastion_perms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key to access the EC2. | `string` | `null` | no |
| <a name="input_lan_cidrs"></a> [lan\_cidrs](#input\_lan\_cidrs) | LAN CIDR blocks for wireguard to access. | `list(string)` | n/a | yes |
| <a name="input_lan_pub_key"></a> [lan\_pub\_key](#input\_lan\_pub\_key) | Wireguard public Key for the LAN host. | `string` | n/a | yes |
| <a name="input_ssh_enabled"></a> [ssh\_enabled](#input\_ssh\_enabled) | Enable SSH on the machine. | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to use for the EC2. | `string` | n/a | yes |
| <a name="input_wan_pub_key"></a> [wan\_pub\_key](#input\_wan\_pub\_key) | Wireguard public key for the WAN host. | `string` | n/a | yes |
| <a name="input_wireguard_cidr"></a> [wireguard\_cidr](#input\_wireguard\_cidr) | CIDR for wireguard to use. | `string` | `"172.27.3.0/29"` | no |
| <a name="input_wireguard_port"></a> [wireguard\_port](#input\_wireguard\_port) | Ingress port for wireguard | `number` | `51820` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_ip"></a> [ec2\_ip](#output\_ec2\_ip) | IP of EC2 |
| <a name="output_pub_key_arn"></a> [pub\_key\_arn](#output\_pub\_key\_arn) | ARN of the SSM parameter |
| <a name="output_wireguard_addr"></a> [wireguard\_addr](#output\_wireguard\_addr) | Address of the wireguard instance. |
<!-- END_TF_DOCS -->