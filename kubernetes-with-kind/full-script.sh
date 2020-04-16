#vagrant ssh
#sudo su

#step 1
/vagrant/install-docker.sh
which docker 
docker --version

#step 2
/vagrant/install-go.sh
which go 
go version

##RUN Mannually form command promt
export PATH=$PATH:/usr/local/go/bin

#step 3
/vagrant/install-kubectl.sh
which kubectl
kubectl version --client

#step 4
GO111MODULE="on" go get sigs.k8s.io/kind@v0.7.0 
ls 
export PATH=$PATH:/root/go/bin
which kind 
kind version 

#step 5
kind create cluster --config /vagrant/kind-config.yaml

#Step 6
kind get clusters
kubectl -n kube-system get all
kubectl get nodes -o wide #Note that we have one HA Proxy LoadBalancer 
kubectl get sc
docker ps
#in kube config we have HA Proxy LB Entry
#vi .kube/config

#Step 7
kubectl run nginx --image nginx




