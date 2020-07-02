**Jenkins CI CD Pipeline in Kubernetes**

# Prerequisite

## 1. Provision kubernetes custer 
[vagrant-provisioning-kubeadm](https://github.com/koolkravi/kubernetes-playground/tree/master/vagrant-provisioning-kubeadm)

```
vagrant up
```
k-master    10.0.0.5  2GB 2 CPU
k-worker01  10.0.0.6  1GB 1 CPU
k-worker02  10.0.0.7  1GB 1 CPU

```
sudo kubectl get nodes
sodu kubectl get nodes -o wide
sudo kubectl get cs

mkdir $HOME/.kube
scp vagrant@10.0.0.5:/home/vagrant/.kube/config $HOME/.kube/config
```

```
$ kubectl cluster-info
Kubernetes master is running at https://10.0.0.5:6443
KubeDNS is running at https://10.0.0.5:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.


$ kubectl get nodes -o wide
NAME         STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k-master     Ready    master   5h18m   v1.18.4   10.0.0.5      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.12
k-worker01   Ready    <none>   4h59m   v1.18.4   10.0.0.6      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.12
k-worker02   Ready    <none>   4h34m   v1.18.4   10.0.2.15     <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.12

$ kubectl get cs
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-0               Healthy   {"health":"true"}

$ kubectl version --short
Client Version: v1.15.2
Server Version: v1.18.4
```

## Install Helm and tiller - Automated script from 2 to 4

[prerequisite script on master](/docs/1-prerequisite-install-helm_k-master.sh)
[Refer install helm](/docs/install-helm.md)

vagrant@k-master:~$
### 2. install helm
```
wget https://get.helm.sh/helm-v2.16.9-linux-amd64.tar.gz
tar -zxvf helm-v2.16.9-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

```
which helm
/usr/local/bin/helm
```

### 3. install  tiller
```
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
```

```
helm init --service-account tiller
```

## 4. Setup private docker registry
```
docker run -d -p 5000:5000 --restart=always --name registry -v docker:/var/lib/registry registry:2
stsytemctl status  docker
docker volume ls
```

# Deploy jenkins master in k8s cluster (Automated script from step 5 to 8)

run on all nodes (master and worker)
[scrip share.sh](/docs/2-share.sh)

run from master
[scrip 3-jenkis-sh_k-master.sh](/docs/3-jenkins-sh_k-master.sh)

## 5. change permission on each node (automated script from 5 to 8)

```
ll /var/run/docker.sock
sudo chmod 666 /var/run/docker.sock    // old 660
```

## 6. Set insecure docker to access registry

```
sudo vi /etc/docker/daemon.json

{
  "insecure-registries" : ["10.0.0.5:5000"]
}

```

```
sudo systemctl daemon-reload
sudo systemctl reload docker
sudo systemctl restart docker
```

## 7. Create PV (script 3-jenkis-sh_k-master.sh)

```
kubectl create -f docs/pv-jenkins-pv1.yaml
kubectl create -f docs/pvc-jenkins-pv1.yaml
```

## 8. Create jenkins.values file (script 3-jenkis-sh_k-master.sh)

```
helm search jenkins
helm inspect values stable/jenkins > /vagrant/docs/deploy/jenkins.values
```

```
vi /tmp/jenkins.values
```

change as below

admin password
memory to  memory: "2048Mi"
serviceType: NodePort
nodePort: 32323
installPlugins   add
    - blueocean:1.18.1
    - kubernetes-cd:2.0.0
agent:
  image: "joao29a/jnlp-slave:alpine-docker"
  tag: "latest"	

 volumes: []
    - type: HostPath
    - hostPath: /var/run/docker.sock
    - mountPath: /var/run/docker.sock

### install jenkins chart (script 3-jenkis-sh_k-master.sh)

```
#helm install stable/jenkins --name jenkins --values /tmp/jenkins.values --namespace jenkins   --dry-run
helm install stable/jenkins --name jenkins --values /tmp/jenkins.values --namespace jenkins

kubectl get all -n jenkins
helm status jenkins
kubectl get pvc jenkins -n jenkins -o yaml
```

```
vagrant@k-master:~$ kubectl get all
output:

NAME                           READY   STATUS    RESTARTS   AGE
pod/jenkins-5f99cdcddc-87v6k   2/2     Running   0          7m22s

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/jenkins         NodePort    10.98.191.214   <none>        8080:32323/TCP   7m22s
service/jenkins-agent   ClusterIP   10.98.210.25    <none>        50000/TCP        7m22s
service/kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP          8h

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jenkins   1/1     1            1           7m22s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/jenkins-5f99cdcddc   1         1         1       7m22s

```

```
help delete jenkins --purge
```

## 9. test 

```
kubectl logs jenkins-86f5bdf78-f5rsg -c jenkins -n jenkins
kubectl logs -f jenkins-86f5bdf78-f5rsg -c jenkins -n jenkins
```

```
kubectl get service jenkins -n jenkins -o wide
NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE   SELECTOR
jenkins   NodePort   10.99.108.125   <none>        8080:32323/TCP   15h   app.kubernetes.io/component=jenkins-master,app.kubernetes.io/instance=jenkins

kubectl get deployment jenkins -n jenkins -o wide
NAME      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS                  IMAGES                                             SELECTOR
jenkins   1/1     1            1           15h   jenkins,jenkins-sc-config   jenkins/jenkins:lts,kiwigrid/k8s-sidecar:0.1.144   app.kubernetes.io/component=jenkins-master,app.kubernetes.io/instance=jenkins

kubectl get nodes -o wide
NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k-master     Ready    master   24h   v1.18.4   10.0.0.5      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.12
k-worker01   Ready    <none>   23h   v1.18.4   10.0.0.6      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.12
k-worker02   Ready    <none>   23h   v1.18.4   10.0.0.7      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.12
```

```
10.0.0.5:32323
10.0.0.6:32324
10.0.0.6:32325
```

create test job
watch kubectl get pods -n jenkins

```
helm list
help rollback jebkins or rebision
helm delete my jenkins --purge
```









## Reference
- [Docker Private Registry](https://docs.docker.com/registry/deploying/)

- Run docker command without sudo
```
sudo setfacl -m user:$USER:rw /var/run/docker.sock
```

- command to check port (docker registry is listening at port 5000)
```
vagrant@k-master:~$ netstat -nlt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 127.0.0.1:9099          0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN
tcp        0      0 10.0.0.5:2379           0.0.0.0:*               LISTEN
tcp        0      0 10.0.0.5:2380           0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:2381          0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:10257         0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:179             0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:10259         0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:10249         0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:41385         0.0.0.0:*               LISTEN
tcp6       0      0 :::10250                :::*                    LISTEN
tcp6       0      0 :::10251                :::*                    LISTEN
tcp6       0      0 :::6443                 :::*                    LISTEN
tcp6       0      0 :::10252                :::*                    LISTEN
tcp6       0      0 :::111                  :::*                    LISTEN
tcp6       0      0 :::10256                :::*                    LISTEN
tcp6       0      0 :::22                   :::*                    LISTEN
tcp6       0      0 :::5000                 :::*                    LISTEN
```

# Issues

1. issue 1
```
vagrant@k-master:~$ helm install stable/jenkins --name jenkins --values /tmp/jenkins.values --namespace jenkins
Error: forwarding ports: error upgrading connection: unable to upgrade connection: pod does not exist

Solution: https://github.com/helm/helm/issues/1455
```

2. Issue 2

The connection to the server 10.0.0.5:6443 was refused - did you specify the right host or port

Solution: ref: https://github.com/kubernetes/kubernetes/issues/66748
```
rm  /etc/docker/daemon.json
sudo systemctl start docker
```

3. docker private insecure registries
https://stackoverflow.com/questions/42211380/add-insecure-registry-to-docker

4. Troubleshoot with the k8s node ip

ref: https://networkinferno.net/trouble-with-the-kubernetes-node-ip
```
sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#edit the file and append the --node-ip 10.0.0.7
#reload the daemon and restart the kubelet service. Run 

sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

5. issue 5

vagrant@k-master:~$ 

helm install stable/jenkins --name jenkins --namespace jenkins
Error: failed to download "stable/jenkins" (hint: running `helm repo update` may help)

solution: disconnect from LAN

6. Debug jenkins PODs

kubectl -n <namespace-name> logs -p  <pod name>
kubectl -n <namespace-name> describe pod <pod name>
kubectl logs -p  jenkins-5f99cdcddc-nh8z7


7. Issue 7:
$ kubectl get nodes -o wide
Unable to connect to the server: dial tcp 10.0.0.5:6443: connectex: No connection could be made because the target machine actively refused it.

Solution: 
netstat -pnlt | grep 6443
netstat -a | grep 6443
lsof -i

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo docker rm -f $(sudo docker ps -aq)
systemctl restart kubelet

kubeadm reset 
journalctl -xeu kubelet

## UBUNTU
sudo ufw status verbose
sudo ufw disable
## turn on
sudo ufw enable
## make sure your kube-apiserver can get through port 6443
sudo ufw allow 6443/tcp
## try telnet from another host to your apiserver
telnet MASTER-IP 6443

I have to do vagranat destroy 


https://github.com/kubernetes/kubernetes/issues/23726
https://www.thegeekdiary.com/troubleshooting-kubectl-error-the-connection-to-the-server-x-x-x-x6443-was-refused-did-you-specify-the-right-host-or-port/
https://medium.com/@texasdave2/troubleshoot-kubectl-connection-refused-6f5445a396ed

8. 





# Reference:
```
vagrant init hashicorp/bionic64
```