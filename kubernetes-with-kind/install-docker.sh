#!/bin/bash
# Step 1: Setup Docker Repository
echo "Step 1: Setup Docker Repository"
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Step 2: install docket engine
echo "Step 2: install docket engine"
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
echo "Step 3: verify docker engine is installed"
sudo docker run hello-world

#Step 3: Configure docker to start on boot

echo "Step 3: Configure docker to start on boot"
sudo systemctl enable docker
systemctl start docker
