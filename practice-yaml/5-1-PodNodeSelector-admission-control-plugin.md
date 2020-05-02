# PodNodeSelector admission control plugin

- How to use PodNodeSelector admission control plugin to assign pod that are deployed to a specific namespace to be scheduled on specific set of worker nodes. 
- To run production workloads and dev workloads in a separate set of hardware. 
- use node selectors to target appropriate nodes.

## Step 1: label node
```
kubectl label node k-worker01 env=dev
kubectl label node k-worker02 env=prod

kubectl get node k-worker01 --show-labels
```

# Step 2: Enable admission control plugin

```
vagrant@k-master:~$ ls /etc/kubernetes/manifests/
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```

### update kubeapi server pod to enable admission control plugin 

add PodNodeSelector
```
sudo vi  kube-apiserver.yaml
.
.
containers:
  - command:
    - kube-apiserver
    - --advertise-address=10.0.0.5
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction,PodNodeSelector
.
.
```

```
$ kubectl -n kube-system get pod
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-75d56dfc47-9w2dg   1/1     Running   3          2d10h
calico-node-75phf                          1/1     Running   2          12h
calico-node-c2rkz                          1/1     Running   3          2d9h
calico-node-vzq22                          1/1     Running   3          2d10h
coredns-66bff467f8-f7h47                   1/1     Running   3          2d10h
coredns-66bff467f8-xls5s                   1/1     Running   3          2d10h
etcd-k-master                              1/1     Running   3          2d10h
kube-apiserver-k-master                    1/1     Running   0          31s
kube-controller-manager-k-master           1/1     Running   9          2d10h
kube-proxy-f4qcw                           1/1     Running   3          2d10h
kube-proxy-jtl6l                           1/1     Running   2          12h
kube-proxy-zxfxb                           1/1     Running   3          2d9h
kube-scheduler-k-master                    1/1     Running   8          2d10h

```
# Step 3: Edit namespace and add annotation

```
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/node-selector: name-of-node-selector
  name: namespace3
```

```
kubectl create namespace dev
kubectl create namespace prod
```

```
$ kubectl get namespace
NAME              STATUS   AGE
default           Active   2d10h
dev               Active   75s
kube-node-lease   Active   2d10h
kube-public       Active   2d10h
kube-system       Active   2d10h
prod              Active   68s
```

```
kubectl edit namespave dev
.
.
  name: dev
  annotation:
    scheduler.alpha.kubernetes.io/node-selector: "env=dev"
.
.
```

```
kubectl edit namespave prod
.
.
  name: dev
  annotation:
    scheduler.alpha.kubernetes.io/node-selector: "env=prod"
.
.
```

#Step 4: Deploy nginx into dev namespace

```
vagrant@k-master:~$ watch kubectl -n dev get pods -o wide
```

```
$ kubectl -n dev run nginx --image nginx --replicas 4
```

### all pods are schedules on k-worker01 because k-worker01 node is labelsa as "env=dev"

```
$ kubectl -n dev get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/nginx-76df748b9-hhjp9   1/1     Running   0          3m27s
pod/nginx-76df748b9-pmcns   1/1     Running   0          3m27s
pod/nginx-76df748b9-wtpnw   1/1     Running   0          3m27s
pod/nginx-76df748b9-xm2cd   1/1     Running   0          3m27s


NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   4/4     4            4           3m27s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-76df748b9   4         4         4       3m27s

```

```
$ kubectl -n dev get deploy nginx -o wide
NAME    READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES   SELECTOR
nginx   4/4     4            4           4m50s   nginx        nginx    run=nginx
```

```
kubectl -n dev get pod  nginx-76df748b9-hhjp9 -o yaml | less
.
.
 nodeName: k-worker01
  nodeSelector:
    env: dev
  priority: 0
.
.
```

```
kubectl -n dev delete deploy nginx
```

#Step 5: Deploy nginx into prod namespace

```
vagrant@k-master:~$ watch kubectl -n prod get pods -o wide
kubectl -n prod run nginx --image nginx --replicas 4
```

### all pods are schedules on k-worker02 because k-worker02 node is labelsa as "env=prod"

```
$ kubectl -n prod get all -o wide
NAME                        READY   STATUS    RESTARTS   AGE    IP               NODE         NOMINATED NODE   READINESS GATES
pod/nginx-76df748b9-dc9vr   1/1     Running   0          112s   192.168.57.130   k-worker02   <none>           <none>
pod/nginx-76df748b9-fwgtt   1/1     Running   0          112s   192.168.57.129   k-worker02   <none>           <none>
pod/nginx-76df748b9-sqgfv   1/1     Running   0          112s   192.168.57.131   k-worker02   <none>           <none>
pod/nginx-76df748b9-vs5l6   1/1     Running   0          112s   192.168.57.132   k-worker02   <none>           <none>


NAME                    READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES   SELECTOR
deployment.apps/nginx   4/4     4            4           112s   nginx        nginx    run=nginx

NAME                              DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES   SELECTOR
replicaset.apps/nginx-76df748b9   4         4         4       112s   nginx        nginx    pod-template-hash=76df748b9,run=nginx
```

```
$ kubectl -n prod delete deploy nginx
```


##Ref :
- https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#podnodeselector

