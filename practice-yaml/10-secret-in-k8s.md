# How to use Secrets in Kubernetes Cluster.

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

## Steps:  How to use secret?
e.g. mysql user name or password pull from secret file
two ways
- using yaml file
- using kubectl create secret comand

## using yaml file

### Step 1: create yaml file

5-secrets.yaml
```
apiVersion: v1
kind: secret
metadata:
  name: secret-demo
type: Opaque
data: 
  username: <base64 encoded value>
  password: <base64 encoded value>
```

### Step 2: Create base64 string usng below command and put into yaml file

```
echo -n 'kubeadmin' | base64
a3ViZWFkbWlu

echo -n 'mypassword' | base64
bXlwYXNzd29yZA==
```

### Step 3: 
```
kubectl create -f 5-secrets.yaml
```

```
$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-wswfh   kubernetes.io/service-account-token   3      3d11h
secret-demo           Opaque                                2      42s
```
```
$ kubectl get secret secret-demo -o yaml
apiVersion: v1
data:
  password: bXlwYXNzd29yZA==
  username: a3ViZWFkbWlu
kind: Secret
metadata:
  creationTimestamp: "2020-05-10T09:05:09Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:password: {}
        f:username: {}
      f:type: {}
    manager: kubectl.exe
    operation: Update
    time: "2020-05-10T09:05:09Z"
  name: secret-demo
  namespace: default
  resourceVersion: "27775"
  selfLink: /api/v1/namespaces/default/secrets/secret-demo
  uid: caf8952a-5566-4cea-9e6b-1239a6fb4012
type: Opaque
```

```
$ kubectl describe secret secret-demo
Name:         secret-demo
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  10 bytes
username:  9 bytes
```

clean
```
kubectl delete secret secret-demo
```

## using kubectl create secret comand

### Step 1: help command

```
$ kubectl create secret --help
Create a secret using specified subcommand.

Available Commands:
  docker-registry Create a secret for use with a Docker registry
  generic         Create a secret from a local file, directory or literal value
  tls             Create a TLS secret

Usage:
  kubectl create secret [flags] [options]

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

```
kubectl create generic --help
```

### Step 2: create command

``` 
kubectl create secret generic secret-demo --from-literal=username=kubeadmin --from-literal=password=mypassword
```

```
$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-wswfh   kubernetes.io/service-account-token   3      3d11h
secret-demo           Opaque                                2      45s
```

```
$ kubectl describe secret secret-demo
Name:         secret-demo
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  10 bytes
username:  9 bytes
```

- using user name and password stored in file
```
vi username
vi password
kubectl create secret generic secret-demo --from-file=username
```

## How to use secrete in pod specification
- As environment variable - secret will be mounted as environment variable which we can use within container
- mounted as volume - secret will be mounted as indivisual file inside container which we can reference

### using secret As environment variable

5-pod-secret-env.yaml
```
apiVersion: v1
kind: Pod
metadata: 
  name: busybox
spec:
  containers:
  - image: busybox
    name: busybox
    command: ["/bin/sh"]
    args: ["-c","sleep 600"]
    env:
    - name:  myusername
      valueFrom:
        secretKeyRef:
          name: secret-demo
          key: username
```

```
$ kubectl get pod -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
busybox                         1/1     Running   0          57s     192.168.114.2    k-worker01   <none>           <none>
nginx-deploy-64cd6c58c7-zzd67   1/1     Running   1          3d10h   192.168.57.130   k-worker02   <none>           <none>
```

```
 kubectl exec -it busybox -c busybox -- sh
# env | grep myusername
echo $myusername
```

- advantage , you just need to update secret file

```
kubectl delete pod busybox
/ # env | grep myusername
myusername=kubeadmin
/ # echo $myusername
kubeadmin
```

```
kubectl delete pod busybox
```

### using secret as volume mount

5-pod-secret-volume.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  volumes:
  - name: secret-volume
    secret:
      secretName: secret-demo
  containers:
  - image: busybox
    name: busybox
    command: ["/bin/sh"]
    args: ["-c","sleep 600"]
    volumeMounts:
    - name: secret-volume
      mountPath: /mydata
```


```
kubectl create -f 5-pod-secret-volume.yaml
```

```
$ kubectl get pods -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
busybox                         1/1     Running   0          2m50s   192.168.114.3    k-worker01   <none>           <none>
nginx-deploy-64cd6c58c7-zzd67   1/1     Running   1          3d11h   192.168.57.130   k-worker02   <none>           <none>
```

```
kubectl exec busybox --it  -- sh
/ # env | grep myusername
/ # ls /mydata
password  username
/ # cat /mydata/username; echo
kubeadmin
/ # cat /mydata/password; echo
mypassword
```

### you can update secret dynamically and pod gets updated values
- env dont get updated but volume gets updated dynamically

```
$ echo -n 'randompassword' | base64
cmFuZG9tcGFzc3dvcmQ=
```

```
update password with new password above and add another key name
 vi 5-secrets.yaml
```

```
kubectl apply -f 5-secrets.yaml
```

```
$ kubectl describe secret secret-demo
Name:         secret-demo
Namespace:    default
Labels:       <none>
Annotations:
Type:         Opaque

Data
====
name:      4 bytes
password:  14 bytes
username:  9 bytes
```

 pod is updated with new key
```
vagrant@k-master:~$ kubectl exec -it busybox busybox -- sh
/ # ls /mydata
name      password  username
/ # cat /mydata/name; echo
ravi
/ # cat /mydata/username; echo
kubeadmin
/ # cat /mydata/password; echo
randompassword
name      password  username
```

- another check to see if pod gets updated password in secret 
```
$ echo -n 'randompasswordcheck' | base64
cmFuZG9tcGFzc3dvcmRjaGVjaw==

# update vi 5-secrets.yaml with new password
kubectl apply -f 5-secrets.yaml

vagrant@k-master:~$ kubectl exec -it busybox busybox -- sh
/ # ls /mydata
name      password  username
/ # cat /mydata/password; echo
randompasswordcheck
```

```
 kubectl delete pod busybox
```





