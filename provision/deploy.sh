#!/bin/bash -e
apt update
apt install -y wireguard-tools
wg genkey > /etc/wireguard/private-ec2.key
wg pubkey < /etc/wireguard/private-ec2.key > /etc/wireguard/public.key

wg genkey > /etc/wireguard/private-home.key
wg pubkey < /etc/wireguard/private-home.key > /etc/wireguard/public-home.key

wg genkey > /etc/wireguard/private-external.key
wg pubkey < /etc/wireguard/private-external.key >/etc/wireguard/public-external.key

tee -a /etc/sysctl.conf <<EOF
net.ipv6.conf.all.forwarding = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $(</etc/wireguard/private-ec2.key)
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT
Address = 172.22.99.1/29 # Wireguard internal network. Can't overlap with home network
[Peer]
# External host
PublicKey = $(</etc/wireguard/public-external.key)
AllowedIPs = 172.22.99.4/32
[Peer]
# Machine to VPN to
PublicKey = $(</etc/wireguard/public-home.key)
AllowedIPs = 172.22.99.3/32, ${home_cidr}
EOF