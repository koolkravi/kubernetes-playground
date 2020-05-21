# Set up Traefik Ingress on kubernetes Bare Metal Cluster
How to set up Ingress controller using Traefik  in your Kubernetes cluster. 
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

## Inggess controller Traefik


## Install HAProxy Load Balancer

### Step 1: 
IP of node : 10.0.0.7 (k-worker02)
vagrant ssh k-worker02

```
sudo apt-get update
sudo apt-get -y install haproxy
```

```
vagrant@k-worker02:~$ haproxy -v
HA-Proxy version 1.8.8-1ubuntu0.10 2020/04/03
Copyright 2000-2018 Willy Tarreau <willy@haproxy.org>
```

### Step2: Edit HAProxy configuration file

```
 vi /etc/haproxy/haproxy.cfg
```
Add below at end of haproxy.cfg
```
frontend http_front
  bind *:80
  stats uri /haproxy?stats
  default_backend http_back

backend http_back
  balance roundrobin
  server kube 10.0.0.6:80
  #server kube 10.0.0.7:80
```

- k-worker01   10.0.0.6       

### Step 3: 
```
vagrant@k-worker02:~$ systemctl status haproxy
systemctl enable haproxy
systemctl start haproxy
sudo systemctl reload haproxy
```

test
```
http://<load balancer public IP>/haproxy?stats
curl 10.0.0.7/haproxy?stats
```

## Step 4: Create ingress controller 

https://docs.traefik.io/v1.7/user-guide/kubernetes/
click example link
https://github.com/containous/traefik/tree/v1.7/examples/k8s


### 4.1 RBAC - cluster role binding
```
$ kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-rbac.yaml

out:
clusterrole.rbac.authorization.k8s.io/traefik-ingress-controller created
clusterrolebinding.rbac.authorization.k8s.io/traefik-ingress-controller created
```

```
$ kubectl get namespace

out:
NAME              STATUS   AGE
default           Active   53m
kube-node-lease   Active   53m
kube-public       Active   53m
kube-system       Active   53m
```

```
$ kubectl describe clusterrole traefik-ingress-controller -n kubesystem

out: 
Name:         traefik-ingress-controller
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"rbac.authorization.k8s.io/v1beta1","kind":"ClusterRole","metadata":{"annotations":{},"name":"traefik-ingress-controller"},"...
PolicyRule:
  Resources                    Non-Resource URLs  Resource Names  Verbs
  ---------                    -----------------  --------------  -----
  endpoints                    []                 []              [get list watch]
  secrets                      []                 []              [get list watch]
  services                     []                 []              [get list watch]
  ingresses.extensions         []                 []              [get list watch]
  ingresses.extensions/status  []                 []              [update]
```


### 4.2 : Deploy the Ingress Controller

### two options for deploying the Ingress controller:
two option
- Deploy Traefik using a Deployment or
- Deploy Traefik using a DaemonSet

- Deploy Traefik using a DaemonSet

```
$ kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-ds.yaml

out:
serviceaccount/traefik-ingress-controller created
daemonset.apps/traefik-ingress-controller created
service/traefik-ingress-service created
```

```
$ kubectl get all -n kube-system |  grep traefik

out: 
pod/traefik-ingress-controller-gsf47           1/1     Running   0          3m25s
service/traefik-ingress-service   ClusterIP   10.104.49.148   <none>        80/TCP,8080/TCP          3m25s
daemonset.apps/traefik-ingress-controller   1         1         1       1            1           <none>                        3m25s
```

## Step 5: Deploy nginx

nginx-deploy-main.yaml
```
kubectl apply -f  nginx-deploy-main.yaml -f nginx-deploy-blue.yaml -f nginx-deploy-green.yaml

out:
deployment.apps/nginx-deploy-main created
deployment.apps/nginx-deploy-blue created
deployment.apps/nginx-deploy-green created
```

```
$ kubectl get pods

out:
NAME                                  READY   STATUS    RESTARTS   AGE
nginx-deploy-blue-6bbcfd9788-frww7    1/1     Running   0          71s
nginx-deploy-green-6b85fd4b89-n5bhr   1/1     Running   0          71s
nginx-deploy-main-545f4f6967-pfjn8    1/1     Running   0          71s
```

```
$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   62m
```

## Step 6: create service of type cluster IP

```
kubectl expose deploy nginx-deploy-main --port 80
kubectl expose deploy nginx-deploy-blue --port 80
kubectl expose deploy nginx-deploy-green --port 80

out:
service/nginx-deploy-main exposed
service/nginx-deploy-blue exposed
service/nginx-deploy-green exposed
```

```
$ kubectl get deploy

out:
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deploy-blue    1/1     1            1           2m58s
nginx-deploy-green   1/1     1            1           2m58s
nginx-deploy-main    1/1     1            1           2m58s
```

```
$ kubectl get svc

out:
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes           ClusterIP   10.96.0.1        <none>        443/TCP   64m
nginx-deploy-blue    ClusterIP   10.104.192.195   <none>        80/TCP    71s
nginx-deploy-green   ClusterIP   10.97.130.201    <none>        80/TCP    70s
nginx-deploy-main    ClusterIP   10.109.65.114    <none>        80/TCP    73s
```

## Step 6: Create Ingress Resource (rules)

ingress-resource-2.yaml

```
$ kubectl apply -f ingress-resource-2.yaml

out:
ingress.networking.k8s.io/ingress-resource-2 created
```

```
$ kubectl get ing

out:
NAME                 CLASS    HOSTS                                                              ADDRESS   PORTS   AGE
ingress-resource-2   <none>   nginx.example.com,blue.nginx.example.com,green.nginx.example.com             80      59s
```

```
$ kubectl describe ingress ingress-resource-2

out:
Name:             ingress-resource-2
Namespace:        default
Address:
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host                     Path  Backends
  ----                     ----  --------
  nginx.example.com
                              nginx-deploy-main:80 (192.168.114.4:80)
  blue.nginx.example.com
                              nginx-deploy-blue:80 (192.168.114.2:80)
  green.nginx.example.com
                              nginx-deploy-green:80 (192.168.114.3:80)
Annotations:
.
.
```

## Step 7: make dns entry for haproxy for nginx.example.com
Since we are not using dns server so we will make entry into host file
 
```
sudo vi /etc/hosts
```

```
#haproxy_server_ip nginx.example.com 
10.0.0.7        nginx.example.com
10.0.0.7        blue.nginx.example.com
10.0.0.7        green.nginx.example.com
```

## Step 8: test

```
vagrant@k-master:~$ sudo ufw enable
vagrant@k-worker01:~$ sudo ufw enable

vagrant@k-master:~$ sudo ufw allow from any to any port 80 proto tcp
vagrant@k-worker01:~$ sudo ufw allow from any to any port 80 proto tcp
vagrant@k-worker02:~$ sudo apt install curl
```

```
vagrant@k-worker02:~$ curl nginx.example.com
vagrant@k-worker02:~$ curl blue.nginx.example.com
vagrant@k-worker02:~$ curl green.nginx.example.com
```




## Ref
- https://devops.ionos.com/tutorials/install-and-configure-haproxy-load-balancer-on-ubuntu-1604/
- http://www.haproxy.org/