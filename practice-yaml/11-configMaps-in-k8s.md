# How to use ConfigMaps in your Kubernetes Cluster.
Define enviroment variable , configuration . We dont need to create new image and we just need to update config map and it will get applied

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

## Steps:  How to use ConfigMaps

### Step 1:  create config map  using yaml(6-configmap-1.yaml)
```
kubectl get cm
```

6-configmap-1.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-configmap
data: 
  channel.name: "k8splayground"
  channel.owner: "Ravi Kumar"
```

```
kubectl create -f 6-configmap-1.yaml
```

```
$ kubectl get cm -o wide
NAME             DATA   AGE
demo-configmap   2      29s
```

```
$ kubectl describe configmap demo-configmap
Name:         demo-configmap
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
channel.name:
----
k8splayground
channel.owner:
----
Ravi Kumar
Events:  <none>
```

```
$ kubectl get cm demo-configmap -o yaml
apiVersion: v1
data:
  channel.name: k8splayground
  channel.owner: Ravi Kumar
kind: ConfigMap
metadata:
  creationTimestamp: "2020-05-13T15:00:43Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:channel.name: {}
        f:channel.owner: {}
    manager: kubectl.exe
    operation: Update
    time: "2020-05-13T15:00:43Z"
  name: demo-configmap
  namespace: default
  resourceVersion: "44759"
  selfLink: /api/v1/namespaces/default/configmaps/demo-configmap
  uid: c4260599-15a3-4653-b66e-06a069caa773
```

### Step 2: create config map using command

```
$ kubectl create cm demo-configmap-1 --from-literal=channel.name=k8splayground --from-literal=channel.owner=ravi
```

```
$ kubectl describe cm demo-configmap-1
Name:         demo-configmap-1
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
channel.name:
----
k8splayground
channel.owner:
----
ravi
Events:  <none>
```

### Step 3: How to use config map in pod - using environment variable

6-pod-configmap-env.yaml
```
metadata:
  name: busybox
spec: 
  containers:
  - image : busybox
    name: busybox
    command: ["/bin/sh"]
    args: ["-c","sleep 600"]
    env:
    - name: CHANNELNAME
      valueFrom:
        configMapKeyRef:
          name: demo-configmap
          key: channel.name
    - name: CHANNELOWNER
      valueFrom:
        configMapKeyRef:
          name: demo-configmap
          key: channel.name
```

```
kubectl create -f 6-pod-configmap-env.yaml
```

```
$ kubectl get pod -o wide
NAME                            READY   STATUS        RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
busybox                         1/1     Running       0          87s     192.168.114.5    k-worker01   <none>           <none>
```

```
vagrant@k-master:~$ kubectl exec -it busybox -- sh
/ # env | grep -i channel
CHANNELOWNER=k8splayground
CHANNELNAME=k8splayground
/ # echo $CHANNELOWNER
k8splayground
/ # echo $CHANNELNAME
k8splayground
```
```
kubectl delete pod busybox
```

### Step 4: How to use config map in pod - using volume

6-pod-configmap-volume.yaml
```
apiVersion: v1
kind: Pod
metadata: 
  name: busybox
spec: 
  volumes:
  - name: demo
    configMap:
      name: demo-configmap
  containers:
  - image: busybox
    name: busybox
    command: ["/bin/sh"]
    args: ["-c","sleep 600"]
    volumeMounts:
    - name: demo
      mountPath: /mydata

```

```
kubectl create -f 6-pod-configmap-volume.yaml
kubectl get pods
```

```
vagrant@k-master:~$ kubectl exec -it busybox -- sh
/ # ls
bin     dev     etc     home    mydata  proc    root    sys     tmp     usr     var
/ # ls mydata
channel.name   channel.owner
/ # env | grep -i channel
/ # ls /mydata
channel.name   channel.owner
/ # cat /mydata/channel.name;echo
k8splayground
/ # cat /mydata/channel.owner;echo
Ravi Kumar
```

```
kubectl edit cm demo-configmap
# update channel name to  k8sok
```

```
$ kubectl describe cm demo-configmap
Name:         demo-configmap
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
channel.name:
----
k8sok
channel.owner:
----
Ravi Kumar
Events:  <none>
```

```
vagrant@k-master:~$ kubectl exec -it busybox -- sh
/ # ls
bin     dev     etc     home    mydata  proc    root    sys     tmp     usr     var
/ # ls /mydata
channel.name   channel.owner
/ # cat /mydata/channel.name; echo
k8sok
```

```
kubectl delete pod busybox
```

### Step 5: How u can use file instead of yaml

/tmp/my.cnf

```
vagrant@k-master:~$ vi /tmp/my.cnf
```

```
pid-file		=/var/run/mysqld/mysqld.pid
socket			=/var/run/mysqls/mysqld.sock
port			=9999
datadir			=/var/lib/mysql
default-storage-server	= InnoDB
character-set-server = utf8
bind-address		= 127.0.0.0
general_log_file	= /var/log/mysql/mysqllog
log_error 			= /var/log/mysql/error.log
```

```
vagrant@k-master:~$ kubectl create cm mysql-demo-config --from-file=/tmp/my.cnf
```

```
$ kubectl get cm mysql-demo-config -o yaml
out: 
apiVersion: v1
data:
  my.cnf: "pid-file\t\t=/var/run/mysqld/mysqld.pid\nsocket\t\t\t=/var/run/mysqls/mysqld.sock\nport\t\t\t=9999\ndatadir\t\t\t=/var/lib/mysql\ndefault-storage-server\t=
    InnoDB\ncharacter-set-server = utf8\nbind-address\t\t= 127.0.0.0\ngeneral_log_file\t=
    /var/log/mysql/mysqllog\nlog_error \t\t\t= /var/log/mysql/error.log\n"
kind: ConfigMap
metadata:
  creationTimestamp: "2020-05-13T16:05:13Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:my.cnf: {}
    manager: kubectl
    operation: Update
    time: "2020-05-13T16:05:13Z"
  name: mysql-demo-config
  namespace: default
  resourceVersion: "53660"
  selfLink: /api/v1/namespaces/default/configmaps/mysql-demo-config
  uid: f20cef65-40cb-4556-9753-2835362e1b59
```

```
kubectl delete cm mysql-demo-config
```

### Step 5: How to use config created from file inside pod 

6-configmap-2.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-demo-config
data: 
  my.cnf: |
    [mysqld]
    pid-file        = /var/run/mysqld/mysqld.pid
    socket          = /var/run/mysqld/mysqld.sock
    port            = 3306
    datadir         = /var/lib/mysql
    default-storage-engine = InnoDB
    character-set-server = utf8
    bind-address            = 127.0.0.1
    general_log_file        = /var/log/mysql/mysql.log
    log_error = /var/log/mysql/error.log
```

```
kubectl create -f  6-configmap-2.yaml
```

```
$ kubectl get cm mysql-demo-config -o yaml
out: 
apiVersion: v1
data:
  my.cnf: |
    [mysqld]
    pid-file        = /var/run/mysqld/mysqld.pid
    socket          = /var/run/mysqld/mysqld.sock
    port            = 3306
    datadir         = /var/lib/mysql
    default-storage-engine = InnoDB
    character-set-server = utf8
    bind-address            = 127.0.0.1
    general_log_file        = /var/log/mysql/mysql.log
    log_error = /var/log/mysql/error.log
kind: ConfigMap
metadata:
  creationTimestamp: "2020-05-13T16:11:30Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:my.cnf: {}
    manager: kubectl.exe
    operation: Update
    time: "2020-05-13T16:11:30Z"
  name: mysql-demo-config
  namespace: default
  resourceVersion: "54520"
  selfLink: /api/v1/namespaces/default/configmaps/mysql-demo-config
  uid: 57702fe3-45e5-4908-9709-bcd8a9e2ae4f

```

How to use config map inside pos

6-pod-configmap-mysql-volume.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec: 
  volumes:
  - name: mysql-config
    configMap:
      name: mysql-demo-config
      items:
        - key: my.cnf
          path: my.cnf
  containers:
  - image: busybox
    name: busybox
    command: ["/bin/sh"]
    args: ["-c","sleep 600"]
    volumeMounts:
    - name: mysql-config
      mountPath: /mydata
```

```
kubectl create -f  6-pod-configmap-mysql-volume.yaml
```


```
vagrant@k-master:~$ kubectl exec -it busybox -- sh
/ # ls
bin     dev     etc     home    mydata  proc    root    sys     tmp     usr     var
/ # ls /mydata
my.cnf

/ # cat /mydata/my.cnf
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
port            = 3306
datadir         = /var/lib/mysql
default-storage-engine = InnoDB
character-set-server = utf8
bind-address            = 127.0.0.1
general_log_file        = /var/log/mysql/mysql.log
log_error = /var/log/mysql/error.log
```

edit the 6-configmap-2.yaml and  chnage port 8888
```
vagrant@k-master:~$ kubectl edit cm mysql-demo-config
```

check if port is change

```
vagrant@k-master:~$ kubectl exec -it busybox -- sh
/ # ls /mydata
my.cnf
/ # cat  /mydata/my.cnf
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
port            = 8888
datadir         = /var/lib/mysql
default-storage-engine = InnoDB
character-set-server = utf8
bind-address            = 127.0.0.1
general_log_file        = /var/log/mysql/mysql.log
log_error = /var/log/mysql/error.log
```

```
kubectl delete pod busybox
kubectl dlete cm mysql-demo-config
```
