**Jenkins CI CD Pipeline in Kubernetes**

# version 2

# Prerequisite

## 1. Provision kubernetes custer 
[vagrant-provisioning-kubeadm](https://github.com/koolkravi/kubernetes-playground/tree/master/vagrant-provisioning-kubeadm)

```
vagrant up
```

k-master    10.0.0.5  2GB 2 CPU
k-worker01  10.0.0.6  1GB 1 CPU
k-worker02  10.0.0.7  1GB 1 CPU

### some commands
```
kubectl cluster-info
kubectl get nodes -o wide
kubectl get cs
kubectl version --short

mkdir $HOME/.kube
scp vagrant@10.0.0.5:/home/vagrant/.kube/config $HOME/.kube/config
```

## 2. Install Helm, tiller and Setup private docker registry

### Run below script from k-master
[Run 1-prerequisite-install-helm_k-master.sh Script on master](https://github.com/koolkravi/kubernetes-playground/blob/master/ci-cd-using-jenkins-helmchart-and-kubernetes/docs/1-prerequisite-install-helm_k-master.sh)

[Refer install-helm.md for detail](https://github.com/koolkravi/kubernetes-playground/blob/master/ci-cd-using-jenkins-helmchart-and-kubernetes/docs/install-helm.md)

### some commands
```
which helm
/usr/local/bin/helm

curl http://localhost:5000/v2/_catalog
curl http://localhost:5000/v2
```

## 3. Change permission of docker.sock and run docker command without sudo

### Run below script on all nodes (k-master and k-workers)
[scrip 2-share.sh](https://github.com/koolkravi/kubernetes-playground/blob/master/ci-cd-using-jenkins-helmchart-and-kubernetes/docs/2-share.sh)

## 4. Create PV, PVC and Deploy jenkins using helm in k8s cluster

### Run below script from k-master
[scrip 3-jenkis-sh_k-master.sh](/docs/3-jenkins-sh_k-master_v2.sh)

script is using /docs/version2/jenkins.values

```
/vagrant/docs/3-jenkins-sh_k-master_v2.sh
```

### Some Commands

```
kubectl get all -n jenkins
helm status jenkins
kubectl get pvc jenkins -n jenkins -o yaml

kubectl describe pods <<pod name>> -n jenkins
kubectl logs <<pod name>> -c jenkins -n jenkins

helm delete jenkins --purge
```

## 5. Test Jenkins UI

### Run Below URL from your browser to open jenkins UI

```
10.0.0.5:32323
```

### Create test JOB
create test job
watch kubectl get pods -n jenkins

### Some commands
```
#kubectl exec my-pod -c my-container -- ls / 
kubectl exec jenkins-f54d8f657-lpjst -c jenkins -n jenkins -- ls /

kubectl top pod POD_NAME --containers


kubectl logs jenkins-86f5bdf78-f5rsg -c jenkins -n jenkins
kubectl logs -f jenkins-86f5bdf78-f5rsg -c jenkins -n jenkins

kubectl get service jenkins -n jenkins -o wide
kubectl get deployment jenkins -n jenkins -o wide
kubectl get nodes -o wide

helm list
help rollback jebkins or rebision
helm delete my jenkins --purge
```

## 6. deploy a application using jenkinks pipelines

Flow 
Code in Git hub->Jenkins build and deploy (Jenkinsfile)-> Kubernetes cluster

Use blu ocean to create pipeline
git mywebapp repo

[Code in Git hub]{https://github.com/koolkravi/jenkins-playground}

### Some commands
```
kubectl get pods
kubecrl describe <<myweb pod>>
```

```
vagrant@k-master:~$ kubectl get services -o wide
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        8d    <none>
myweb        NodePort    10.97.168.232   <none>        80:32223/TCP   12m   app=myweb

vagrant@k-master:~$ kubectl get deployment -o wide
NAME    READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                            SELECTOR
myweb   1/1     1            1           12m   myweb        10.0.0.5:5000/koolkravi/myweb:1   app=myweb

```

## 7. access myweb app

```
10.0.0.6:32224
10.0.0.7:32225
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

8. upgrade jenkins plugin
Credentials Binding 1.22. to 1.23
Kubernetes 1.25.7  to 1.26.2

9. Jenkins Build error
Issue: 
ocker build -t 10.0.0.5:5000/koolkravi/myweb:2 .
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post http://%2Fvar%2Frun%2Fdocker.sock/v1.38/build?buildargs=%7B%7D&cachefrom=%5B%5D&cgroupparent=&cpuperiod=0&cpuquota=0&cpusetcpus=&cpusetmems=&cpushares=0&dockerfile=Dockerfile&labels=%7B%7D&memory=0&memswap=0&networkmode=default&rm=1&session=uy7yijhvlx6i256zjewan38sl&shmsize=0&t=10.0.0.5%3A5000%2Fkoolkravi%2Fmyweb%3A2&target=&ulimits=null&version=1: dial unix /var/run/docker.sock: connect: permission denied
script returned exit code 1

Solution: on each node run below
```
sudo chmod 666 /var/run/docker.sock
```

# Reference:
```
vagrant init hashicorp/bionic64
```
https://github.com/justmeandopensource/playjenkins
Jenkins Pipeline
https://www.jenkins.io/doc/book/pipeline/

Jenkins Blueocean Plugin
https://plugins.jenkins.io/blueocean-analytics-tools/

Jenkins Kubernetes Continuous Deployment Plugin
https://www.jenkins.io/doc/pipeline/steps/kubernetes-cd/

docker registry
https://docs.docker.com/registry/deploying/
https://stackoverflow.com/questions/39716623/access-private-docker-registry-in-browser
