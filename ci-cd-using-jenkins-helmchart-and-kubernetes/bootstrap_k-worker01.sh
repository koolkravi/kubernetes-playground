#!/bin/bash

#Step 10 Join the cluster
echo "[Worker step 1] join the cluster"
sudo apt-get update
sudo apt-get install sshpass
echo "hi" "$USER"
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@k-master.example.com:/vagrant/token/joincluster.sh /vagrant/token/joincluster.sh
#sshpass -p "vagrant" scp vagrant@k-master.example.com:/tmp/joincluster.sh /tmp/joincluster.sh

bash /vagrant/token/joincluster.sh

