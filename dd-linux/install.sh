#/bin/bash
mkdir -p /netboot && cd /netboot

rgeo=`wget -qO- http://myip.rpc.im/country_code`

if [ "$rgeo" == "CN" ]; then
  repo=https://mirrors.tuna.tsinghua.edu.cn/alpine/edge
else
  repo=https://dl-cdn.alpinelinux.org/alpine/edge
fi

wget $repo/releases/x86_64/netboot/vmlinuz-virt --no-check-certificate
wget $repo/releases/x86_64/netboot/initramfs-virt --no-check-certificate
modl=$repo/releases/x86_64/netboot/modloop-virt

cat >> /etc/grub.d/40_custom <<EOF
menuentry "Alpine Linux Minimal" {
    search --set=root --file /netboot/vmlinuz-virt
    linux /netboot/vmlinuz-virt console=tty0 console=ttyS0,115200 ip=dhcp modloop=$modl alpine_repo=$repo/main/
    initrd /netboot/initramfs-virt
}
EOF

sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT="Alpine Linux Minimal"/' /etc/default/grub

update-grub
reboot
