# Single-host Kubernetes cluster equipped with Calico.
ref:https://docs.projectcalico.org/getting-started/kubernetes/quickstart

##Prerequisite:
- create VM 2gb ram and 2 cpus
```
vagrant up
```
##Steps

#step1:
installed kubeadm
```
	run Step 2 to Step 5 3/3 from https://github.com/koolkravi/kubernetes-playground/blob/master/vagrant-provisioning-kubeadm/bootstrap.sh
```
#step2:
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

#step3:
```
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#Step4:
```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

#Step5:
Confirm that all of the pods are running
```
	vagrant@ubuntuvm01:~$ kubectl get pods -n kube-system
```
output : 
	NAME                                       READY   STATUS    RESTARTS   AGE
	calico-kube-controllers-555fc8cc5c-4rdnp   1/1     Running   0          3m58s
	calico-node-tzfwt                          1/1     Running   0          3m58s
	coredns-66bff467f8-2fwbv                   1/1     Running   0          5m44s
	coredns-66bff467f8-jhhrr                   1/1     Running   0          5m44s
	etcd-ubuntuvm01                            1/1     Running   0          5m58s
	kube-apiserver-ubuntuvm01                  1/1     Running   0          5m58s
	kube-controller-manager-ubuntuvm01         1/1     Running   0          5m58s
	kube-proxy-fgp59                           1/1     Running   0          5m43s
	kube-scheduler-ubuntuvm01                  1/1     Running   0          5m58s


#Step6: Remove the taints on the master so that you can schedule pods on it
```
vagrant@ubuntuvm01:~$ kubectl taint nodes --all node-role.kubernetes.io/master-
```
output
node/ubuntuvm01 untainted

#step7:Confirm that you now have a node in your cluster with the following command
```
kubectl get nodes -o wide
```
output : 
vagrant@ubuntuvm01:~$ kubectl get nodes -o wide
NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
ubuntuvm01   Ready    master   25m   v1.18.1   10.0.2.15     <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8


#Next Steps :
- Secure a simple application using the Kubernetes NetworkPolicy API
- Control ingress and egress traffic using the Kubernetes NetworkPolicy API
- Create a user interface that shows blocked and allowed connections in real time
ref:https://docs.projectcalico.org/getting-started/kubernetes/quickstart


	