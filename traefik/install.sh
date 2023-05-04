#!/bin/bash


#二进制安装traefik
echo "开始安装二进制"
curl -o traefik.tar.gz -L https://github.com/traefik/traefik/releases/download/v2.10.1/traefik_v2.10.1_linux_amd64.tar.gz
tar zxvf traefik.tar.gz -C /usr/local/bin traefik
rm -f traefik.tar.gz
traefik version

echo "配置systemctl"
mkdir -p /etc/traefik/dynamic
echo "下载配置文件"
curl -o /etc/traefik/traefik.yml -L https://raw.githubusercontent.com/UTOPIA-Moderate/docker/main/traefik/traefik.yml
curl -o /etc/traefik/dynamic/dashboard.yml -L https://raw.githubusercontent.com/UTOPIA-Moderate/docker/main/traefik/dashboard.yml

echo "创建acme.json 并修改权限644"
mkdir -p /home/traefik && touch /home/traefik/acme.json && chmod 644 /home/traefik/acme.json

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
