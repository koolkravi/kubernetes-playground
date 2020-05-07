# NFS Persistent Volume in Kubernetes Cluster

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

## Steps: setup nfs server on master

### Step 1: install nfs server on k-master

```
sudo apt update
sudo apt install nfs-kernel-server
```

```
systemctl status  nfs-server.service
sudo cat /proc/fs/nfsd/versions
```

### Step 2: create directory

```
sudo mkdir -p /srv/nfs4/kubedata
```

```
sudo chmod -R 777 /srv/nfs4
```

### Step 3: Export the directory

```
sudo vi /etc/exports
/srv/nfs4/kubedata		10.0.0.0/24(rw,sync,no_subtree_check)
```

```
vagrant@k-master:~$ sudo exportfs -rav
out:
exporting 10.0.0.0/24:/srv/nfs4/kubedata
```

To view the current active exports and their state
```
vagrant@k-master:~$ sudo exportfs -v
out: 
/srv/nfs4/kubedata
                10.0.0.0/24(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

```
vagrant@k-master:~$ showmount -e
out: 
Export list for k-master:
/srv/nfs4/kubedata 10.0.0.0/24
```

### Step 4: check workers if we can mount bfs volumes
```
vagrant ssh k-worker01
ping 10.0.0.5
vagrant@k-worker01:~$ showmount -e 10.0.0.5
out: 
Export list for 10.0.0.5:
/srv/nfs4/kubedata 10.0.0.0/24
```

```
sudo mount -t nfs -o vers=4 10.0.0.5:/srv/nfs4/kubedata /mnt
```

```
vagrant@k-worker01:~$ mount | grep kubedata
10.0.0.5:/srv/nfs4/kubedata on /mnt type nfs4 (rw,relatime,vers=4.0,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.0.6,local_lock=none,addr=10.0.0.5)
```

```
sudo umount /mnt
```

```
vagrant ssh k-worker01
ping 10.0.0.5
showmount -e 10.0.0.5
sudo mount -t nfs -o vers=4 10.0.0.5:/srv/nfs4/kubedata /mnt

mount | grep kubedata
umount /mnt
```

### Step 5: create pv 

4-pv-nfs.yaml
```
kubectl create -f 4-pv-nfs.yaml
```

```
$ kubectl get pv

NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv-nfs-pv1   1Gi        RWX            Retain           Available           manual                  92s

```

### Step 6: create pvc

4-pv-nfs.yaml
```
kubectl create -f 4-pv-nfs.yaml
```

```
$ kubectl get pvc

NAME          STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-nfs-pv1   Bound    pv-nfs-pv1   1Gi        RWX            manual         12s


```

### Step 7: create a html file on master 

```
sudo vi /svc/nfs4/kubedata/index.html

<h1> Welcome k8s </h1>
```

### Step 8: Use PV from POD  - create deployment nginx-deploy

4-nfs-nginx.yaml
```
kubectl create -f 4-nfs-nginx.yaml
```

```
$ kubectl get deploy -o wide
NAME           READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES   SELECTOR
nginx-deploy   1/1     1            1           51s   nginx        nginx    app=nginx
```

```
$ kubectl get pods -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
nginx-deploy-64cd6c58c7-zzd67   1/1     Running   0          2m28s   192.168.57.129   k-worker02   <none>           <none>

```

### Step 9: go to k-worker01/02 shell and check 
```
vagrant@k-worker02:~$ mount | grep kubedata
10.0.0.5:/srv/nfs4/kubedata on /var/lib/kubelet/pods/45947e30-ae6f-43e6-bd09-446bb52d624b/volumes/kubernetes.io~nfs/pv-nfs-pv1 type nfs4 (rw,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.0.7,local_lock=none,addr=10.0.0.5)

```

```
kubectl exec -it nginx-deploy-64cd6c58c7-zzd67 -- /bin/sh
#ls /usr/share/nginx/html
index.html
#cat /usr/share/nginx/html/index.html
<h1> welcome k8s change </h2>

```

### Step 10: create service

```
kunectl expose deploy nginx-deploy --port 80 --type NodePort
```
### Step 11: access from k-worker02

```
$ kubectl get service -o wide
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE    SELECTOR
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        102m   <none>
nginx-deploy   NodePort    10.107.194.74   <none>        80:30984/TCP   39s    app=nginx
```

```
vagrant@k-worker02:~$ curl 10.0.0.7:30984
<h1> welcome k8s </h2>

vagrant@k-worker01:~$ curl 10.0.0.6:30984
<h1> welcome k8s </h2>

vagrant@k-master:~$ curl 10.0.0.5:30984
<h1> welcome k8s </h2>

```

### Step 12: update index.html pressnt in k-master 

```
vi /svc/nfs4/kubedata/index.html
```

### Step 13: access service from k-worker02

```
curl 10.0.0.7:30984
```

### Step 14: clean the resouces

```
kubectl delete svc nginx-deploy
ubectl delete deploy nginx-deploy
```

```
sudo systemctl stop nfs-server
sudo systemctl disable nfs-server
sudo vi /ect/export # remove entry
sudo rm srv/nfs4
 
```

## Ref 
- nfs server : Installing the NFS server.md

## issues : exec command throw below error

```
-  vagrant@k-worker02:~$ kubectl exec -it nginx-deploy-64cd6c58c7-zzd67 -- /bin/sh
- error: unable to upgrade connection: pod does not exist
```

### fix
- fix: https://stackoverflow.com/questions/51154911/kubectl-exec-results-in-error-unable-to-upgrade-connection-pod-does-not-exi
- https://github.com/kubernetes/kubernetes/issues/63702

### Step 1 : add Environment="KUBELET_EXTRA_ARGS=--node-ip=<worker IP address>"
on k-worker02
```
Environment="KUBELET_EXTRA_ARGS=--node-ip=10.0.0.7"
```

```
vagrant@k-worker02:~$ sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
content

# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
Environment="KUBELET_EXTRA_ARGS=--node-ip=10.0.0.7"
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```
### Step 2.
```
systemctl daemon-reload
systemctl restart kubelet
Run : kubectl get nodes -o wide , Now you'll see the ip of worker1 has changed.

vagrant@k-worker02:~$ kubectl get nodes -o wide
NAME         STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k-master     Ready    master   166m   v1.18.2   10.0.0.5      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8
k-worker01   Ready    <none>   154m   v1.18.2   10.0.0.6      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8
k-worker02   Ready    <none>   140m   v1.18.2   10.0.0.7      <none>        Ubuntu 18.04.3 LTS   4.15.0-58-generic   docker://19.3.8

```
### Step 3. on k-worker01 add below  and perform step 2.

```
Environment="KUBELET_EXTRA_ARGS=--node-ip=10.0.0.6"
```