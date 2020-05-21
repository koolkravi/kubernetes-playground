# Horizontal Pod Autoscaler in Kubernetes

## Basic Setup : Create 3 VMs (one Master and Two workers)

```
cd \kubernetes-playground\vagrant-provisioning-kubeadm
vagrant up
```

### Copy kube config from master to host to use kubectl command
```
mkdir $HOME/.kube
scp vagrant@10.0.0.5:/home/vagrant/.kube/config $HOME/.kube/config

```
$ kubectl version --short
Client Version: v1.15.2
Server Version: v1.18.3
```

kubectl cluster-info

```
$ kubectl get node -o wide
NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINE   R-RUNTIME
k-master     Ready    master   43m   v1.18.3   10.0.0.5      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker:/   /19.3.9
k-worker01   Ready    <none>   28m   v1.18.3   10.0.0.6      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker:/   /19.3.9
```

## Prerequisite
- metrics server 
	https://github.com/kubernetes-sigs/metrics-server
	https://github.com/kubernetes-sigs/metrics-server.git
- Resource Limit set for deployment
 
