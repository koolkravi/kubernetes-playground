# Set up Nginx Ingress in Kubernetes Bare Metal
How to set up Ingress controller using Nginx in your Kubernetes cluster. 
Traffic routing in Kubernetes cluster is taken care automatically if we use one of the cloud provider. 
But if your cluster is in bare metal, we are left with few choices.

## Basic Setup : Create 3 VMs (one Master and Two workers)

```
cd \kubernetes-playground\vagrant-provisioning-kubeadm
vagrant up
```

### Copy kube config from master to host to use kubectl command
```
mkdir $HOME/.kube
scp vagrant@10.0.0.5:/home/vagrant/.kube/config $HOME/.kube/config

kubectl cluster-info
vagrant@k-master:~$ kubectl get node -o wide
NAME         STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k-master     Ready    master   112m   v1.18.2   10.0.0.5      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8
k-worker01   Ready    <none>   100m   v1.18.2   10.0.0.6      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8
k-worker02   Ready    <none>   86m    v1.18.2   10.0.2.15     <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8
```

## Concept - Ingtess controller
It will create below Resource
namespace
service account
cluster role
cluster role binding
config Map
Daemon set

## Various Ingress controller
nginx
nginx +
Traefic

## Step 1: Install HAProxy Load Balancer

```
sudo apt-get update
sudo apt-get -y install haproxy
```

```
haproxy -v

HA-Proxy version 1.8.8-1ubuntu0.10 2020/04/03
Copyright 2000-2018 Willy Tarreau <willy@haproxy.org>
```
- note : latesr version  http://www.haproxy.org/download/2.1/src/haproxy-2.1.4.tar.gz

## Step2: Edit HAProxy configuration file

```
sudo vi /etc/haproxy/haproxy.cfg
```
Add below at end of haproxy.cfg
```
frontend http_front
  bind *.80
  stats uri /haproxy?stats
  default_backend http_back

backend http_back
  balance roundrobin
  server kube 10.0.0.6:80
  server kube 10.0.0.7:80
```

- k-worker01   10.0.0.6       
- k-worker02   10.0.0.7  

## Step 3: 
```
systemctl status haproxy
systemctl enable haproxy
systemctl start haproxy

netstat -nltp
```

## Step 4: Create ingress controller 

https://github.com/nginxinc/kubernetes-ingress

```
git clone https://github.com/nginxinc/kubernetes-ingress.git
cd kubernetes-ingress/deployments/
```

Installation instruction- Installation with Manifests
```
https://github.com/nginxinc/kubernetes-ingress/blob/master/deployments/README.md
click here link
https://docs.nginx.com/nginx-ingress-controller/installation/
```
### 4.1 Configure RBAC - Create a namespace and a service account for the Ingress controller:
```
kubectl apply -f common/ns-and-sa.yaml
```

```
$ kubectl get namespace
NAME              STATUS   AGE
default           Active   9d
kube-node-lease   Active   9d
kube-public       Active   9d
kube-system       Active   9d
nginx-ingress     Active   42s

```
### 4.2 Configure RBAC - Create a cluster role and cluster role binding for the service account:

```
kubectl apply -f rbac/rbac.yaml
```

### 4.3 Create Common Resources - Create a secret with a TLS certificate and a key for the default server in NGINX:

```
kubectl apply -f common/default-server-secret.yaml
```

### 4.4 Create Common Resources - Create a config map for customizing NGINX configuration:

```
kubectl apply -f common/nginx-config.yaml
```

### 4.5 : Deploy the Ingress Controller

### two options for deploying the Ingress controller:

- Deployment. Use a Deployment if you plan to dynamically change the number of Ingress controller replicas.
- DaemonSet. Use a DaemonSet for deploying the Ingress controller on every node or a subset of nodes.

- Use a DaemonSet

```
kubectl apply -f daemon-set/nginx-ingress.yaml
```

```
$ kubectl get all -n nginx-ingress  -o wide
NAME                      READY   STATUS    RESTARTS   AGE    IP               NODE         NOMINATED NODE   READINESS GATES
pod/nginx-ingress-fmpqn   1/1     Running   1          103s   192.168.114.11   k-worker01   <none>           <none>
pod/nginx-ingress-jsgh9   1/1     Running   1          103s   192.168.57.131   k-worker02   <none>           <none>



NAME                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE    CONTAINERS      IMAGES                     SELECTOR
daemonset.apps/nginx-ingress   2         2         2       2            2           <none>          103s   nginx-ingress   nginx/nginx-ingress:edge   app=nginx-ingress
```

## Step 5: Deploy nginx

nginx-deploy-main.yaml
```
kubectl apply -f  nginx-deploy-main.yaml
```

```
kubectl get all
```

## Step 6: create service of type cluster IP

```
kubectl expose deploy nginx-deploy-main --port 80
```
- if you dont specify type then default is cluster port

```
$ kubectl get all -o wide
NAME                                     READY   STATUS    RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
pod/busybox                              1/1     Running   15         2d9h    192.168.114.10   k-worker01   <none>           <none>
pod/nginx-deploy-64cd6c58c7-sl6df        1/1     Running   1          2d10h   192.168.114.9    k-worker01   <none>           <none>
pod/nginx-deploy-main-545f4f6967-pm8v4   1/1     Running   0          8m13s   192.168.57.132   k-worker02   <none>           <none>


NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
service/kubernetes          ClusterIP   10.96.0.1       <none>        443/TCP        9d    <none>
service/nginx-deploy        NodePort    10.107.194.74   <none>        80:30984/TCP   9d    app=nginx
service/nginx-deploy-main   ClusterIP   10.106.23.98    <none>        80/TCP         99s   run=nginx-main


NAME                                READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES   SELECTOR
deployment.apps/nginx-deploy        1/1     1            1           9d      nginx        nginx    app=nginx
deployment.apps/nginx-deploy-main   1/1     1            1           8m13s   nginx        nginx    run=nginx-main

NAME                                           DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES   SELECTOR
replicaset.apps/nginx-deploy-64cd6c58c7        1         1         1       9d      nginx        nginx    app=nginx,pod-template-hash=64cd6c58c7
replicaset.apps/nginx-deploy-main-545f4f6967   1         1         1       8m13s   nginx        nginx    pod-template-hash=545f4f6967,run=nginx-main
```

## Step 6: Create Ingress Resource

ingress-resource-1.yaml

```
kubectl apply -f ingress-resource-1.yaml
```

```
$ kubectl get ing
NAME                 CLASS    HOSTS               ADDRESS   PORTS   AGE
ingress-resource-1   <none>   nginx.example.com             80      95s
```

```
$ kubectl describe ingress ingress-resource-1
Name:             ingress-resource-1
Namespace:        default
Address:
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host               Path  Backends
  ----               ----  --------
  nginx.example.com
                        nginx-deploy-main:80 (192.168.57.132:80)
Annotations:
  kubectl.kubernetes.io/last-applied-configuration:  {"apiVersion":"networking.k8s.io/v1beta1","kind":"Ingress","metadata":{"annotations":{},"name":"ingress-resource-1","namespace":"default"},"spec":{"rules":[{"host":"nginx.example.com","http":{"paths":[{"backend":{"serviceName":"nginx-deploy-main","servicePort":80}}]}}]}}

Events:
  Type    Reason          Age    From                      Message
  ----    ------          ----   ----                      -------
  Normal  AddedOrUpdated  2m33s  nginx-ingress-controller  Configuration for default/ingress-resource-1 was added or updated
  Normal  AddedOrUpdated  2m33s  nginx-ingress-controller  Configuration for default/ingress-resource-1 was added or updated
```


## Step 7: make dns entry for haproxy for nginx.example.com
Since we are not using dns server so we will make entry into host file
 
```
sudo vi /etc/hosts
```

```
haproxy_server_ip nginx.example.com 
```

## Step 8: test

make entry as below host file of you local system
```
10.0.0.5 nginx.example.com
```

run from browser
```
nginx.example.com
```

## Step 9: add multiple application

```
kubectl delete ingress  ingress-resource-1
```

### 9.1 deploy moe applications

nginx-deploy-blue.yaml
```
kubectl apply -f  nginx-deploy-blue.yaml
```

nginx-deploy-green.yaml
```
kubectl apply -f  nginx-deploy-green.yaml
```

```
$ kubectl get all
NAME                                      READY   STATUS    RESTARTS   AGE
pod/busybox                               1/1     Running   18         2d9h
pod/nginx-deploy-64cd6c58c7-sl6df         1/1     Running   1          2d11h
pod/nginx-deploy-blue-6bbcfd9788-m4z9x    1/1     Running   0          2m55s
pod/nginx-deploy-green-6b85fd4b89-zs2zn   1/1     Running   0          59s
pod/nginx-deploy-main-545f4f6967-pm8v4    1/1     Running   0          38m


NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes          ClusterIP   10.96.0.1       <none>        443/TCP        9d
service/nginx-deploy        NodePort    10.107.194.74   <none>        80:30984/TCP   9d
service/nginx-deploy-main   ClusterIP   10.106.23.98    <none>        80/TCP         32m


NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy         1/1     1            1           9d
deployment.apps/nginx-deploy-blue    1/1     1            1           2m55s
deployment.apps/nginx-deploy-green   1/1     1            1           59s
deployment.apps/nginx-deploy-main    1/1     1            1           38m

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-64cd6c58c7         1         1         1       9d
replicaset.apps/nginx-deploy-blue-6bbcfd9788    1         1         1       2m55s
replicaset.apps/nginx-deploy-green-6b85fd4b89   1         1         1       59s
replicaset.apps/nginx-deploy-main-545f4f6967    1         1         1       38m
```

## Step 10: Create service

```
kubectl expose deploy nginx-deploy-blue --port 80
kubectl expose deploy nginx-deploy-green --port 80
```

```
$ kubectl get all
NAME                                      READY   STATUS    RESTARTS   AGE
pod/busybox                               1/1     Running   19         2d9h
pod/nginx-deploy-64cd6c58c7-sl6df         1/1     Running   1          2d11h
pod/nginx-deploy-blue-6bbcfd9788-m4z9x    1/1     Running   0          6m27s
pod/nginx-deploy-green-6b85fd4b89-zs2zn   1/1     Running   0          4m31s
pod/nginx-deploy-main-545f4f6967-pm8v4    1/1     Running   0          42m


NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/kubernetes           ClusterIP   10.96.0.1        <none>        443/TCP        9d
service/nginx-deploy         NodePort    10.107.194.74    <none>        80:30984/TCP   9d
service/nginx-deploy-blue    ClusterIP   10.109.104.193   <none>        80/TCP         43s
service/nginx-deploy-green   ClusterIP   10.97.250.244    <none>        80/TCP         50s
service/nginx-deploy-main    ClusterIP   10.106.23.98     <none>        80/TCP         35m


NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy         1/1     1            1           9d
deployment.apps/nginx-deploy-blue    1/1     1            1           6m27s
deployment.apps/nginx-deploy-green   1/1     1            1           4m31s
deployment.apps/nginx-deploy-main    1/1     1            1           42m

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-64cd6c58c7         1         1         1       9d
replicaset.apps/nginx-deploy-blue-6bbcfd9788    1         1         1       6m27s
replicaset.apps/nginx-deploy-green-6b85fd4b89   1         1         1       4m31s
replicaset.apps/nginx-deploy-main-545f4f6967    1         1         1       42m
```

## Step 11: Create ingress resource
ingress-resource-2.yaml

```
kubectl apply -f ingress-resource-2.yaml
```

## Step 12: test
Make below entries in local host file
```
10.0.0.5 nginx.example.com
10.0.0.5 blue.nginx.example.com
10.0.0.5 green.nginx.example.com
```

Run from browser
```
nginx.example.com
blue.nginx.example.com
green.nginx.example.com
```

# Clean Up
```
# Clean Up
kubectl delete ing ingress-resource-2
kubectl delete service nginx-deploy-green
kubectl delete service nginx-deploy-blue
kubectl delete service nginx-deploy-main
kubectl delete deploy nginx-deploy-green
kubectl delete deploy nginx-deploy-blue
kubectl delete deploy nginx-deploy-main

kubectl delete DaemonSet nginx-ingress -n nginx-ingress
kubectl delete ConfigMap nginx-config -n nginx-ingress
kubectl delete Secret default-server-secret -n nginx-ingress
kubectl delete ClusterRoleBinding nginx-ingress
kubectl delete ClusterRole nginx-ingress
kubectl delete serviceaccount nginx-ingress
kubectl delete namespace nginx-ingress
```

## Ref
- https://devops.ionos.com/tutorials/install-and-configure-haproxy-load-balancer-on-ubuntu-1604/
- http://www.haproxy.org/