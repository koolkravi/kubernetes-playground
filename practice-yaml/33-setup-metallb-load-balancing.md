# Set up MetalLB Load Balancing for Bare Metal Kubernetes
How to setup load balancing in your Kubernetes cluster using MetalLB project

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

## Steps 
### Step 1. create nginx deployment
 
```
kubectl create deploy nginx --image nginx

out:
deployment.apps/nginx created
```

```
vagrant@k-master:~$ kubectl get all

out:
NAME                        READY   STATUS    RESTARTS   AGE
pod/nginx-f89759699-wm89j   1/1     Running   0          48s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   45m

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           48s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-f89759699   1         1         1       48s

```

### Step 2. create service of type load balancer

```
kubectl expose deploy nginx --port 80 --type Loadbalancer
```

```
vagrant@k-master:~$ kubectl get service nginx
NAME    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx   LoadBalancer   10.108.117.67   <pending>     80:32585/TCP   46s
```

```
vagrant@k-master:~$ kubectl get all

out: 
NAME                        READY   STATUS    RESTARTS   AGE
pod/nginx-f89759699-wm89j   1/1     Running   0          3m3s

NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP        47m
service/nginx        LoadBalancer   10.108.117.67   <pending>     80:32585/TCP   35s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           3m3s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-f89759699   1         1         1       3m3s
```

### Step 3. deploy load balanceer solution

```
kubectl delete service nginx
```

```
https://metallb.universe.tf/installation/
```

3.1 Installation By Manifest
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
```

```
vagrant@k-master:~$ kubectl get namespace

out:
NAME              STATUS   AGE
default           Active   50m
kube-node-lease   Active   50m
kube-public       Active   50m
kube-system       Active   50m
```

```
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

out:
secret/memberlist created
```

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml

out:
podsecuritypolicy.policy/controller configured
podsecuritypolicy.policy/speaker configured
serviceaccount/controller created
serviceaccount/speaker created
clusterrole.rbac.authorization.k8s.io/metallb-system:controller unchanged
clusterrole.rbac.authorization.k8s.io/metallb-system:speaker unchanged
role.rbac.authorization.k8s.io/config-watcher created
role.rbac.authorization.k8s.io/pod-lister created
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:controller unchanged
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:speaker unchanged
rolebinding.rbac.authorization.k8s.io/config-watcher created
rolebinding.rbac.authorization.k8s.io/pod-lister created
daemonset.apps/speaker created
deployment.apps/controller created
```

```
vagrant@k-master:~$ kubectl get all -n metallb-system
NAME                              READY   STATUS    RESTARTS   AGE
pod/controller-57f648cb96-llv2s   1/1     Running   0          2m41s
pod/speaker-282bt                 1/1     Running   0          2m41s
pod/speaker-9pdrj                 1/1     Running   0          2m41s
pod/speaker-l2rjb                 1/1     Running   0          2m41s

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
daemonset.apps/speaker   3         3         3       3            3           beta.kubernetes.io/os=linux   2m41s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller   1/1     1            1           2m41s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-57f648cb96   1         1         1       2m41s
```

Note:
This will deploy MetalLB to your cluster, under the metallb-system namespace. The components in the manifest are:

- The metallb-system/controller deployment. This is the cluster-wide controller that handles IP address assignments.

- The metallb-system/speaker daemonset. This is the component that speaks the protocol(s) of your choice to make the services reachable.

- Service accounts for the controller and speaker, along with the RBAC permissions that the components need to function.

3.2 metallb - define and deploy a configmap

```
https://metallb.universe.tf/configuration/
```
MetalLB remains idle until configured. This is accomplished by creating and deploying a configmap into the same namespace (metallb-system) as the deployment.

Layer 2 Configuration

config.yaml

```
cat <<EOF | kubectl create -f 
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.0.0.20-10.0.0.50
```

```
vagrant@k-master:~$ kubectl create -f config.yaml
configmap/config created
```

```
vagrant@k-master:~$ kubectl describe configmap config -n metallb-system

out:
Name:         config
Namespace:    metallb-system
Labels:       <none>
Annotations:  <none>

Data
====
config:
----
address-pools:
- name: default
  protocol: layer2
  addresses:
  - 10.0.0.20-10.0.0.50

Events:  <none>
```

### Step 4. Expose service as Load balancer

```
kubectl expose deploy nginx --port 80 --type Loadbalancer
```
```
vagrant@k-master:~$ kubectl get service nginx
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
nginx   LoadBalancer   10.109.238.249   10.0.0.20     80:31208/TCP   54s
```

- note:  sudo apt-get install curl

### Step 5.Access nginx
```
#curl LB_IP
curl 10.0.0.20
```

### Step 6.create another service and Expose service as Load balancer

```
kubectl create deploy nginx2 --image nginx
kubectl expose deploy nginx2 --port 80 --type LoadBalancer
```

```
vagrant@k-master:~$ kubectl get svc nginx2
NAME     TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx2   LoadBalancer   10.99.135.253   10.0.0.21     80:30304/TCP   28s
```

### Step 8. access nginx2

```
curl 10.0.0.21
```

## Ref:
- https://www.devtech101.com/2019/02/23/using-metallb-and-traefik-load-balancing-for-your-bare-metal-kubernetes-cluster-part-1/