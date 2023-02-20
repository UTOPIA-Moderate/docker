#!/bin/bash


#二进制安装traefik
echo "开始安装二进制"
curl -o traefik.tar.gz -L https://github.com/traefik/traefik/releases/download/v2.9.6/traefik_v2.9.6_linux_amd64.tar.gz
tar zxvf traefik.tar.gz -C /usr/local/bin traefik
rm -f traefik.tar.gz
traefik version

echo "配置systemctl"
mkdir -p /etc/traefik/

cat <<EOF > /etc/systemd/system/traefik.service
[Unit]
Description=Traefik
Documentation=https://docs.traefik.io

[Service]
Type=simple
ExecStart=/usr/local/bin/traefik
Restart=always
WatchdogSec=1s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable traefik --now
