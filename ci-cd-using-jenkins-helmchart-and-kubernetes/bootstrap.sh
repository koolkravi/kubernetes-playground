#!/bin/bash

# Step1 update host file
echo "[Step 1] Update /etc/hosts file"
#sudo su 
cat >>/etc/hosts<<EOF
10.0.0.5 k-master.example.com k-master
10.0.0.6 k-worker01.example.com k-worker01
EOF

#Step 2 Install, Enable and Start docker Service
echo "[Step 2] Install, Enable and Start docker Service"
sudo apt-get update 
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io				
sudo docker run hello-world

systemctl enable docker
systemctl start docker

# Step 3 Disable Firewalld , disable swap
echo "[Step 3] Disable Firewalld , disable swap"
#systemctl disable firewalld
#systemctl stop firewalld

sed -i '/swap/d' /etc/fstab
swapoff -a

# Step 4 Add sysctl setting for kubernetes networking
echo "[Step 4] Add sysctl setting for kubernetes networking"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
EOF
sysctl --system

# Step 5 Kubernetes Setup
# Step 5 1/3 Kubernetes Setup - Add Repository
echo "[Step 5 1/3] Kubernetes Setup - Add Repository"
sudo apt-get update 
sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Step 5 2/3 Kubernetes Setup - Install Kubernetes kubelet kuneadm and kubectl
echo "[Step 5 2/3] Kubernetes Setup - Install Kubernetes kubelet kuneadm and kubectl"
sudo apt-get update
sudo apt-get install -y kubelet
sudo apt-get install -y kubeadm 
sudo apt-get install -y kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Step 5 3/3 Kubernetes Setup - Enable and Start kubelet service
echo "[Step 5 3/3] Kubernetes Setup - Enable and Start kubelet service"
systemctl enable kubelet
systemctl start kubelet

# Enable ssh password authentication
echo "[Extra Step 1] Enable ssh password authentication"
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[Extra Step 2] Set root password"
echo "root:kubeadmin" | chpasswd

# Update vagrant user's bashrc file
echo "[Extra Step 3] Update vagrant user's bashrc file"
echo "export TERM=xterm" >> /etc/bashrc

