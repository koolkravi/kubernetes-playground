# Kubernetes DaemonSets and how to use them in your cluster

DaemonSets is a pod that you can deploy to all nodes in cluster

## Setup : 

### Copy kube config from master to host to use kubectl command
```
mkdir $HOME/.kube
scp vagrant@10.0.0.5:/home/vagrant/.kube/config $HOME/.kube/config
```

## Step 1: 
```
vagrant@k-master:~$ watch kubectl get all -o wide
```

```
$ kubectl apply -f 1-nginx-daemonset.yaml

content:
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
spec:
  selector:
    matchLabels:
      demotype: nginx-daemonset-demo
  template: 
    metadata:
      labels:
        demotype: nginx-daemonset-demo
    spec: 
      containers:
      - image: nginx
        name: nginx

```

### runs on each worker node
```
vagrant@k-master:~$ kubectl get all -o wide
NAME                        READY   STATUS    RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
pod/nginx-daemonset-265t2   1/1     Running   0          2m22s   192.168.114.28   k-worker01   <none>           <none>
pod/nginx-daemonset-b84cw   1/1     Running   0          2m22s   192.168.57.133   k-worker02   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d11h   <none>

NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE     CONTAINERS   IMAGES  SELECTOR
daemonset.apps/nginx-daemonset   2         2         2       2            2           <none>          2m22s   nginx        nginx   demotype=nginx-daemonset-demo
```

```
kubectl describe daemonset nginx-daemonset
kubectl describe pod nginx-daemonset-265t2
kubectl delete pod nginx-daemonset-b84cw
kubectl delete daemonset nginx-daemonset
```

### some daemonset are allreday runing
```
$ kubectl get daemonset -n kube-system -o wide
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE     CONTAINERS    IMAGES                          SELECTOR
calico-node   3         3         3       3            3           beta.kubernetes.io/os=linux   2d11h   calico-node   calico/node:v3.11.2             k8s-app=calico-node
kube-proxy    3         3         3       3            3           kubernetes.io/os=linux        2d11h   kube-proxy    k8s.gcr.io/kube-proxy:v1.18.2   k8s-app=kube-proxy
```

```
kubectl get daemonset kube-proxy  -n kube-system -o yaml
```

## target specific machine
edit 1-nginx-daemonset.yaml and add node selector gpupresent: "true"
```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
spec:
  selector:
    matchLabels:
      demotype: nginx-daemonset-demo
  template: 
    metadata:
      labels:
        demotype: nginx-daemonset-demo
    spec: 
      containers:
      - image: nginx
        name: nginx
      nodeSelector:
        gpupresent: "true"
```

### Assign label to node k-worker02 (gpupresent=true)

```
kubectl get nodes -l gpupresent=true 
kubectl label node k-worker02 gpupresent=true

$ kubectl get nodes -l gpupresent=true
NAME         STATUS   ROLES    AGE   VERSION
k-worker02   Ready    <none>   14h   v1.18.2
```

```
$ kubectl apply -f 1-nginx-daemonset.yaml
```

```
kubectl get all -o wide 

NAME                        READY   STATUS    RESTARTS   AGE   IP               NODE         NOMINATED NODE   READINESS GATES
pod/nginx-daemonset-xfhf7   1/1     Running   0          88s   192.168.57.135   k-worker02   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d12h   <none>

NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR     AGE   CONTAINERS   IMAGES  SELECTOR
daemonset.apps/nginx-daemonset   1         1         1       1            1           gpupresent=true   89s   nginx        nginx   demotype=nginx-daemonset-demo
```

```
kubectl delete daemonset nginx-daemonset
```

