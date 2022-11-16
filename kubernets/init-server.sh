#/bin/bash

##服务器初始化脚本
echo "关闭防火墙"
systemctl disable --now firewalld

##关闭selinux
echo "关闭selinux"
setenforce 0
sed -i 's/enforcing/disabled/' /etc/selinux/config

##关闭swap
echo "关闭swap"
swapoff -a
sed -i '/swap/d' /etc/fstab

##添加hosts信息
cat >> /etc/hosts << EOF
192.168.31.7 master1
192.168.31.8 node1
192.168.31.9 node2
192.168.31.10 node3
EOF

##将桥接的IPv4流量传递到iptables的链
cat >> /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
echo "配置规则生效"
sysctl  --system

##安装 docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
yum makecache fast
yum install docker-ce -y

##更改docker镜像源为阿里云
mkdir -p /etc/docker
tee /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["https://a0j7za8k.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart docker

##安装kubeadm kubelet kubectl
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet --now

##部署kubernetesMaster
kubeadm init \
--apiserver-advertise-address=192.168.31.7 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.25.3 \
--service-cidr=192.188.0.0/12 \
--pod-network-cidr=192.200.0.0/16