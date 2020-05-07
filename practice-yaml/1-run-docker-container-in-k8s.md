# Running Docker Container in Kubernetes Cluster

## Pre-requisite

	[run vagrant up from setup multinode cluster using kuibeadm](https://github.com/koolkravi/kubernetes-playground/tree/master/vagrant-provisioning-kubeadm)

- note : kuibeadm requires 2 cpu for master

- check 
```
kubectl cluster-info 
kubectl get nodes
```

## Step 1: run busybox container

```
vagrant ssh k-worker01
kubectl get all -o wide
sudo docker images
kubectl get pod --watch
```

```
vagrant ssh k-master
kubectl run myshell -it --image busybox -- sh
ping google .com
exit
kubectl delete pod myshell

kubectl run myshell --rm -it --image busybox -- sh
#exit
```

## Step 2: run nginx container

```
#kubectl run nginx --image nginx
kubectl create deployment nginx --image=nginx
```

```
vagrant@k-master:~$ kubectl get pod -o wide
NAME                    READY   STATUS    RESTARTS   AGE     IP              NODE         NOMINATED NODE   READINESS GATES
nginx-f89759699-x4jxs   1/1     Running   0          2m10s   192.168.114.7   k-worker01   <none>           <none>
```

### How to access nginx container
- 1. using port forward

```
kubectl port-forward <pod name> 8080:80
vagrant@k-master:~$ curl localhost:8080
vagrant@k-master:~$ kubectl logs nginx
```

```
kubectl scale deploy nginx --replicas 2
```

```
vagrant@k-master:~$ kubectl get deployment -o wide
NAME    READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES   SELECTOR
nginx   2/2     2            2           4m15s   nginx        nginx    app=nginx

vagrant@k-master:~$ kubectl get pod -o wide
NAME                    READY   STATUS    RESTARTS   AGE     IP              NODE         NOMINATED NODE   READINESS GATES
nginx-f89759699-2ttqh   1/1     Running   0          105s    192.168.114.8   k-worker01   <none>           <none>
nginx-f89759699-x4jxs   1/1     Running   0          4m59s   192.168.114.7   k-worker01   <none>           <none>
```

```
kubectl describe pod nginx-f89759699-2ttqh
```

- 2. Using service (create service)

```
vagrant@k-master:~$ kubectl expose deployment nginx --type NodePort --port 80
service/nginx exposed
```

```
vagrant@k-master:~$ kubectl get service nginx
NAME    TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.104.194.192   <none>        80:32242/TCP   4m14s
```

```
vagrant@k-master:~$ kubectl describe svc nginx
Name:                     nginx
Namespace:                default
Labels:                   app=nginx
Annotations:              <none>
Selector:                 app=nginx
Type:                     NodePort
IP:                       10.104.194.192
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  32242/TCP
Endpoints:                192.168.114.7:80,192.168.114.8:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

```
vagrant@k-master:~$ kubectl get pod -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
nginx-f89759699-2ttqh   1/1     Running   0          12m   192.168.114.8   k-worker01   <none>           <none>
nginx-f89759699-x4jxs   1/1     Running   0          15m   192.168.114.7   k-worker01   <none>           <none>
```

```
curl k-worker01:<node port>
vagrant@k-worker01:~$ curl k-worker01:32242
```

## Step 3: generate yaml file

```
kubectl get deploy nginx -o yaml >/vagrant/nginx.yaml
```

```
kubectl get svc nginx -o yaml > /vagrant/nginx-service.yaml
```

edit yaml
```
vi /vagrant/nginx.yaml
vi /vagrant/nginx-service.yaml
```

```
kubectl delete deploy nginx
kubectl delete service nginx
```

```
kubectl create -f /vagrant/nginx.yaml
kubectl create -f /vagrant/nginx-service
```

```
curl k-worker01:<<node port>>
curl k-worker01:32242
```

- clean

```
kubectl delete -f /vagrant/nginx-service.yaml
kubectl delete -f /vagrant/nginx.yaml
```


- ref : [video](https://www.youtube.com/watch?v=-NzB4sPZXwU&list=PL34sAs7_26wNBRWM6BDhnonoA5FMERax0&index=9)
- ref : https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands

## issues .
- 1. Unable to connect to the server: net/http: TLS handshake timeout ->fix:  vagrant destroy and vagrant up 
- 2. copy .kube/config file from master to worker

```
vagrant@k-worker01:~$ mkdir .kube
vagrant@k-worker01:~$ scp k-master.example.com:/home/vagrant/.kube/config /home/vagrant/.kube/config
```


