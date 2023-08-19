#!/bin/bash -e
apt update
apt install -y wireguard-tools iptables
WG_PRIV_KEY=$(wg genkey)
wg pubkey <<<$WG_PRIV_KEY > /home/admin/public.key

tee -a /etc/sysctl.conf <<EOF
net.ipv6.conf.all.forwarding = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $WG_PRIV_KEY
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT
Address = 172.22.99.1/29 # Wireguard internal network. Can't overlap with home network
ListenPort = ${wireguard_port}
[Peer]
# External host
PublicKey = ${wan_wg_public_key}
AllowedIPs = 172.22.99.4/32
[Peer]
# Machine to VPN to
PublicKey = ${internal_wg_public_key}
AllowedIPs = 172.22.99.3/32, ${home_cidr}
EOF

sudo systemctl enable --now wg-quick@wg0.service