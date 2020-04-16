# Installing Kuberetes cluster usig Kind
Kind is a tool for running local Kubernetes clusters using Docker container “nodes”. 
Installtion is done on Ubuntu 18.04.3 LTS 18.04 bionic

# Prerequisite

## 1. Install docker : run script install-docker.sh

```
vagrant@ubuntuvm01:~$ /vagrant/install-docker.sh
```

```
which docker // /usr/bin/docker
docker --version // Docker version 19.03.8, build afacb8b7f0
```

## 2. Install GO : run script install-go.sh

```
vagrant@ubuntuvm01:~$ /vagrant/install-go.sh
```

Script content as below
```
VERSION=1.14.2
OS=linux
ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz
tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PATH:/usr/local/go/bin
#rm go$VERSION.$OS-$ARCH.tar.gz
```

```
which go // /usr/local/go/bin/go
go version //go version go1.14.2 linux/amd64
```

## 3. Install kubectl (optional) : run script install-kubectl.sh

vagrant@ubuntuvm01:~$ /vagrant/install-kubectl.sh

Script content as below
```
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get -y install -y kubectl
```

```
which kubectl // /usr/bin/kubectl
kubectl version --client
```

vagrant@ubuntuvm01:~$ sudo kubectl version --short
Client Version: v1.18.1
Server Version: v1.17.0

# Setup kind Steps

## Step 1
```
GO111MODULE="on" go get sigs.k8s.io/kind@v0.7.0 
```

- ls  //go
- rm -f go1.14.2.linux-amd64.tar.gz

## Step 2
``` 
export PATH=$PATH:go/bin
or
$(go env GOPATH)/bin
```

```
which kind # go/bin/kind
kind version #kind v0.7.0 go1.14.2 linux/amd64
#kind help 
```

## Step 3 : Create default cluster 

```
vagrant@ubuntuvm01:~$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

```
kind create cluster 
```

```
Output : 
vagrant@ubuntuvm01:~$ sudo kind create cluster
Creating cluster "kind" ...
Ensuring node image (kindest/node:v1.17.0) ??
Ensuring node image (kindest/node:v1.17.0) ??
Preparing nodes ??
Writing configuration ??
Starting control-plane ???
Installing CNI ??
Installing StorageClass ??
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind
```

## Step 4 : Verify

```
which kind
ls .kube
sudo kind get clusters
sudo kubectl cluster-info
sudo docker ps
sudo vi .kube/config
sudo kubectl get nodes
sudo kubectl get nodes -o wide
sudo kubectl version --short
sudo kubectl -n kube-system get all
```

```
vagrant@ubuntuvm01:~$ which kind
/home/vagrant/go/bin/kind

vagrant@ubuntuvm01:~$ ls .kube
cache  config  http-cache

vagrant@ubuntuvm01:~$ sudo kind get clusters

vagrant@ubuntuvm01:~$ sudo kubectl cluster-info
Kubernetes master is running at https://127.0.0.1:32768
KubeDNS is running at https://127.0.0.1:32768/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

vagrant@ubuntuvm01:~$ sudo docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                       NAMES
8b4dbfe07eac        kindest/node:v1.17.0   "/usr/local/bin/entr…"   19 minutes ago      Up 18 minutes       127.0.0.1:32768->6443/tcp   kind-control-plane

vagrant@ubuntuvm01:~$ sudo vi .kube/config

vagrant@ubuntuvm01:~$ sudo kubectl get nodes
NAME                 STATUS   ROLES    AGE   VERSION
kind-control-plane   Ready    master   23m   v1.17.0

vagrant@ubuntuvm01:~$ sudo kubectl get nodes -o wide
NAME                 STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION      CONTAINER-RUNTIME
kind-control-plane   Ready    master   23m   v1.17.0   172.17.0.2    <none>        Ubuntu 19.10   4.15.0-58-generic   containerd://1.3.2

vagrant@ubuntuvm01:~$ sudo kubectl version --short
Client Version: v1.18.1
Server Version: v1.17.0

vagrant@ubuntuvm01:~$ sudo kubectl -n kube-system get all
NAME                                             READY   STATUS    RESTARTS   AGE
pod/coredns-6955765f44-9b8v7                     1/1     Running   0          24m
pod/coredns-6955765f44-gbppm                     1/1     Running   0          24m
pod/etcd-kind-control-plane                      1/1     Running   1          25m
pod/kindnet-6gsr5                                1/1     Running   0          24m
pod/kube-apiserver-kind-control-plane            1/1     Running   0          25m
pod/kube-controller-manager-kind-control-plane   1/1     Running   0          25m
pod/kube-proxy-6t279                             1/1     Running   0          24m
pod/kube-scheduler-kind-control-plane            1/1     Running   0          25m

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
service/kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   25m

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
daemonset.apps/kindnet      1         1         1       1            1           <none>                        24m
daemonset.apps/kube-proxy   1         1         1       1            1           beta.kubernetes.io/os=linux   25m

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns   2/2     2            2           25m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/coredns-6955765f44   2         2         2       24m
```

## Step 5: Setup multi node cluster (1 master amd 1 worker)

```
kind delete cluster 
```

```
vagrant@ubuntuvm01:~$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

### a. Create config file 
```
name: kind-config.yaml

content: 
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
```

### b. Create multi node cluster

```
sudo kind create cluster --config /vagrant/kind-config.yaml
```

``` 
vagrant@ubuntuvm01:~$ sudo kind create cluster --config /vagrant/kind-config.yaml
Creating cluster "kind" ...
Ensuring node image (kindest/node:v1.17.0) ??
Preparing nodes ?? ?? ??
Preparing nodes ?? ?? ??
Writing configuration ??
Starting control-plane ???
Installing CNI ??
Installing StorageClass ??
Joining worker nodes ??
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community ??
```

### c. Verify

```
kind get clusters
kubectl -n kube-system get all
kubectl get nodes -o wide #Note that we have one HA Proxy LoadBalancer 
kubectl get sc
docker ps
#in kube config we have HA Proxy LB Entry
#vi .kube/config
```
```
OUTPUT:
**root@ubuntuvm01:/home/vagrant#** kind get clusters
kind

**root@ubuntuvm01:/home/vagrant#** kubectl -n kube-system get all
NAME                                             READY   STATUS    RESTARTS   AGE
pod/coredns-6955765f44-gtw24                     1/1     Running   0          22m
pod/coredns-6955765f44-nn4wb                     1/1     Running   0          22m
pod/etcd-kind-control-plane                      1/1     Running   0          22m
pod/kindnet-8k7ch                                1/1     Running   0          22m
pod/kindnet-chs78                                1/1     Running   0          22m
pod/kube-apiserver-kind-control-plane            1/1     Running   0          22m
pod/kube-controller-manager-kind-control-plane   1/1     Running   0          22m
pod/kube-proxy-m7q9d                             1/1     Running   0          22m
pod/kube-proxy-pjqlh                             1/1     Running   0          22m
pod/kube-scheduler-kind-control-plane            1/1     Running   0          22m

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
service/kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   22m

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
daemonset.apps/kindnet      2         2         2       2            2           <none>                        22m
daemonset.apps/kube-proxy   2         2         2       2            2           beta.kubernetes.io/os=linux   22m

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns   2/2     2            2           22m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/coredns-6955765f44   2         2         2       22m

**root@ubuntuvm01:/home/vagrant#** kubectl get nodes -o wide
NAME                 STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION      CONTAINER-RUNTIME
kind-control-plane   Ready    master   23m   v1.17.0   172.17.0.2    <none>        Ubuntu 19.10   4.15.0-58-generic   containerd://1.3.2
kind-worker          Ready    <none>   23m   v1.17.0   172.17.0.3    <none>        Ubuntu 19.10   4.15.0-58-generic   containerd://1.3.2

**root@ubuntuvm01:/home/vagrant#** kubectl get sc
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  23m

**root@ubuntuvm01:/home/vagrant#** docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                       NAMES
0b76319b3c7c        kindest/node:v1.17.0   "/usr/local/bin/entr…"   26 minutes ago      Up 24 minutes                                   kind-worker
4f105ffdb01d        kindest/node:v1.17.0   "/usr/local/bin/entr…"   26 minutes ago      Up 24 minutes       127.0.0.1:32768->6443/tcp   kind-control-plane
```


## Step 6 Setup multi node cluster (2 master and 2 worker) (HA cluster)

```
sudo kind delete cluster
```

```
vagrant@ubuntuvm01:~$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

### a.Create a file with 2 master and 2 worker   (4 node)
```
Name: kind-config.yaml

Content:

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: worker
- role: worker
```

### b. Create multi node ,  multi master cluster

```
sudo kind create cluster --config /vagrant/kind-config.yaml
```

### c. Verify that we have one 2 master node and 2 worker node

```
sudo kind get clusters
sudo kubectl -n kube-system get all
sudo kubectl get nodes -o wide #Note that we have one HA Proxy LoadBalancer 
sudo kubectl get sc
sudo docker ps
#in kube config we have HA Proxy LB Entry
#vi /root/.kube/config
```

## Step 7 :Deploy sample application nginx

```
kubectl run nginx --image nginx
kubectl get pods -o wide
kubectl get all
kubectl delete pod nginx
#kubectl taint nodes --all node-role.kubernetes.io/master-
#kubectl describe nodes | grep -i taints
kubectl describe pod/nginx -n default' #to see all of the containers in this pod
kubectl exec -it nginx -- /bin/bash  

# from shell run
cat /proc/1/cgroup
root@shell-demo:/# ls /
root@shell-demo:/# cat /proc/mounts
root@shell-demo:/# cat /proc/1/maps
root@shell-demo:/# apt-get update
root@shell-demo:/# apt-get install -y tcpdump
root@shell-demo:/# tcpdump
root@shell-demo:/# apt-get install -y lsof
root@shell-demo:/# lsof
root@shell-demo:/# apt-get install -y procps
root@shell-demo:/# ps aux
root@shell-demo:/# ps aux | grep nginx
```
```
**root@ubuntuvm01:/home/vagrant#** kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          13m   10.244.1.2   kind-worker   <none>           <none>

**root@ubuntuvm01:/home/vagrant#** kubectl get all
NAME        READY   STATUS    RESTARTS   AGE
pod/nginx   1/1     Running   0          18m

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   34m
```
```

# Ref:
1. https://www.youtube.com/watch?v=4p4DqdTDqkk&list=PL34sAs7_26wNBRWM6BDhnonoA5FMERax0&index=61
2. https://kind.sigs.k8s.io/docs/user/quick-start/
3. https://kind.sigs.k8s.io/docs/user/quick-start/
4. setup kind : https://github.com/kubernetes-sigs/kind
4. install kubectl : https://kubernetes.io/docs/tasks/tools/install-kubectl/
5. lsb_release -dirc
6. Get a Shell to a Running Container: https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/
