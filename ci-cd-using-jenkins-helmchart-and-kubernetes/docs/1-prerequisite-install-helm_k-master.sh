#!/bin/bash

# Run docker command without sudo
echo "Run docker command without sudo"

sudo setfacl -m user:$USER:rw /var/run/docker.sock

# Step 2. install helm
echo "Step 2. install helm"

wget https://get.helm.sh/helm-v2.16.9-linux-amd64.tar.gz
tar -zxvf helm-v2.16.9-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm version --short

# Step 3. install tiller
echo "Step 3. install tiller"

kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

helm init --service-account tiller

# Step 4. setup private registry
echo "Step 4. setup private registry" 

docker run -d -p 5000:5000 --restart=always --name registry -v docker:/var/lib/registry registry:2
systemctl status  docker
docker volume ls

# curl http://localhost:5000/v2/_catalog
# https://localhost:5000/v2