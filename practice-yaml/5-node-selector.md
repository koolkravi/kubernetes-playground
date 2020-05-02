# How you can use nodeselector to schedule pods to specific nodes

## Step 1 : Basic Setup

```
cd /kubernetes-playground/vagrant-provisioning-kubeadm
vagrant up
```

### Copy kube config from master to host to use kubectl command
```
mkdir $HOME/.kube
scp vagrant@10.0.0.5:/home/vagrant/.kube/config $HOME/.kube/config
```

```
vagrant@k-master:~$ kubectl cluster-info
Kubernetes master is running at https://10.0.0.5:6443
KubeDNS is running at https://10.0.0.5:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

vagrant@k-master:~$ kubectl get node -o wide
NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k-master     Ready    master   42h   v1.18.2   10.0.0.5      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8
k-worker01   Ready    <none>   42h   v1.18.2   10.0.0.6      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8
```

```
watch kubectl get nodes -o wide
```

## Step 2: attach alabel to node

```
$ kubectl get node k-master --show-labels
NAME       STATUS   ROLES    AGE   VERSION   LABELS
k-master   Ready    master   43h   v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k-master,kubernetes.io/os=linux,node-role.kubernetes.io/master=

$ kubectl get node k-worker01 --show-labels
NAME         STATUS   ROLES    AGE   VERSION   LABELS
k-worker01   Ready    <none>   43h   v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k-worker01,kubernetes.io/os=linux
```

```
kubectl label node k-worker01.com demoserver=true
```

```
$ kubectl get node k-worker01 --show-labels
NAME         STATUS   ROLES    AGE   VERSION   LABELS
k-worker01   Ready    <none>   43h   v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,demoserver=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=k-worker01,kubernetes.io/os=linux
```


## Step 3: Use label : modify deployment to use label : add nodeSelector
### use 1-nginx-deployment.yaml
```
.
.
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
      nodeSelector:
        demoserver: "true"
.
.

```
### check that pods are provisoned on k-worker01 as label is attahed

```
$ kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP               NODE         NOMINATED NODE   READINESS GATES
nginx-6d994756cf-dttcs   1/1     Running   0          21s   192.168.114.20   k-worker01   <none>           <none>
nginx-6d994756cf-jp7bf   1/1     Running   0          21s   192.168.114.21   k-worker01   <none>           <none>
nginx-6d994756cf-rhtc2   1/1     Running   0          21s   192.168.114.22   k-worker01   <none>           <none>
```

```
kubectl describe pod nginx-6d994756cf-dttcs
out
Node-Selectors:  demoserver=true
```

### scale // pod will be scheduled on k-worker01
```
kubectl scale deploy nginx --replicas 4
```

### clean
```
kubectl delete deploy nginx
```

