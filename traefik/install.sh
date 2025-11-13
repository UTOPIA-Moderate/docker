#!/bin/bash

# 设置GitHub仓库信息

REPO_OWNER="traefik"
REPO_NAME="traefik"
RELEASES_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"

apt install jq -y

# 获取系统类型
SYSTEM_ARCH=$(uname -m)
if [[ $SYSTEM_ARCH == "x86_64" ]]; then
    ARCH="linux_amd64"
elif [[ $SYSTEM_ARCH == "aarch64" ]]; then
    ARCH="linux_arm64"
else
    echo "Unsupported architecture: $SYSTEM_ARCH"
    exit 1
fi

# 获取最新release的下载链接
DOWNLOAD_URL=$(curl -s $RELEASES_URL | jq -r ".assets[] | select(.browser_download_url | contains(\"$ARCH.tar.gz\")) | .browser_download_url")

# 设置下载的文件名
FILENAME=$(basename $DOWNLOAD_URL)

# 下载最新的gz文件
curl -LO  $DOWNLOAD_URL

#解压文件
tar -vxf $FILENAME -C /usr/local/bin traefik

# 清理下载的文件
rm $FILENAME

echo |traefik version

echo "配置systemctl"
mkdir -p /etc/traefik/dynamic
echo "下载配置文件"
curl -o /etc/traefik/traefik.yml -L https://raw.githubusercontent.com/UTOPIA-Moderate/docker/main/traefik/traefik.yml
curl -o /etc/traefik/dynamic/def-gzip.yml -L https://raw.githubusercontent.com/UTOPIA-Moderate/docker/main/traefik/def-gzip.yml

echo "创建acme.json 并修改权限600"
mkdir -p /home/traefik && touch /home/traefik/acme.json && chmod 600 /home/traefik/acme.json

echo "下载并解压完成"

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
