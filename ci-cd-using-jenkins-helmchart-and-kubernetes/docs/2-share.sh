#!/bin/bash

# Run docker command without sudo
echo "Run docker command without sudo"

sudo setfacl -m user:$USER:rw /var/run/docker.sock

# Step 5-1. Set insecure docker to access registry
echo "Step 5-1. Set insecure docker to access registry"

sudo cp /vagrant/docs/daemon.json /etc/docker/

# Step 5-1. reload docker
echo "Step 5-2. reload docker"

sudo systemctl daemon-reload
sudo systemctl reload docker
sudo systemctl restart docker

# Step 6. change permission on each node
echo "Step 6. change permission on each node"
sudo chmod 666 /var/run/docker.sock
# ll /var/run/docker.sock