#!/bin/bash

# step 6 Initialize Kubernetes Cluster
echo "[Master Step 1] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=10.0.0.5 --pod-network-cidr=192.168.0.0/16

#Step 7 copy kube config file to use kubectl command
echo "[Master Step 2] copy kube config file to use kubectl command"
mkdir /home/vagrant/.kube
sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube

#Step 8 Deploy calico network
echo "[Master Step 3] Deploy calico network"
su - vagrant -c "kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml"

#Step 9 cluster join command
echo "[Master Step 4] cluster join command"
kubeadm token create --print-join-command > /vagrant/token/joincluster.sh


