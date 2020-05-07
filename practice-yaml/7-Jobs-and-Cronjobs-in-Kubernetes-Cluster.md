# How to schedule jobs and cronjobs to Kubernetes Cluster

## Basic Setup : 

```
cd \kubernetes-playground\vagrant-provisioning-kubeadm
vagrant up
```

### Copy kube config from master to host to use kubectl command
```
mkdir $HOME/.kube
scp vagrant@10.0.0.5:/home/vagrant/.kube/config $HOME/.kube/config
```

## Step 1:  create file 2-job.yaml

```
watch kubectl get all -o wide
```

```
apiVersion: batch/v1
kind: Job
metadata:
  name: helloworld
spec:
  template:
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["echo","Hello Kubernetes!!!"]
      restartPolicy: Never
```

```
$ kubectl apply -f 2-job.yaml
```

```
kubectl get all -o wide                                                            

NAME                   READY   STATUS      RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
pod/helloworld-zzjzg   0/1     Completed   0          2m33s   192.168.57.136   k-worker02   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d12h   <none>

NAME                   COMPLETIONS   DURATION   AGE     CONTAINERS   IMAGES    SELECTOR
job.batch/helloworld   1/1           8s         2m33s   busybox      busybox   controller-uid=298e2990-5f4e-45b7-aaab-524459f24252
```

```
$ kubectl logs helloworld-zzjzg
Hello Kubernetes!!!
```

```
kubectl describe job helloworld | less
'
'
Parallelism:    1
Completions:    1
Start Time:     Sun, 03 May 2020 02:01:59 +0200
Completed At:   Sun, 03 May 2020 02:02:07 +0200
Duration:       8s
Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
'
'

```
kubectl delete job helloworld 
```

## Step 2:  edit  file 2-job.yaml to run for a minitus

```
vi 2-job.yaml
content

apiVersion: batch/v1
kind: Job
metadata:
  name: helloworld
spec:
  template:
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sleep","60"]
      restartPolicy: Never

```
```
kubectl apply -f 2-job.yaml
kubectl delete job helloworld 
```

## Step 3:  run job multiple iteration
vi 2-job.yaml
completions: 2

```
apiVersion: batch/v1
kind: Job
metadata:
  name: helloworld
spec:
  completions: 2
  template:
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["echo","Hello-K8S"]
      restartPolicy: Never

```

```
kubectl apply -f 2-job.yaml
```

```
kubectl get all -o wide                                                            

NAME                   READY   STATUS      RESTARTS   AGE   IP               NODE         NOMINATED NODE   READINESS GATES
pod/helloworld-5jdxr   0/1     Completed   0          39s   192.168.57.139   k-worker02   <none>           <none>
pod/helloworld-5klv7   0/1     Completed   0          43s   192.168.57.138   k-worker02   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d12h   <none>

NAME                   COMPLETIONS   DURATION   AGE   CONTAINERS   IMAGES    SELECTOR
job.batch/helloworld   2/2           8s         43s   busybox      busybox   controller-uid=8de582f6-a40e-4ba5-9075-8c224404a7be
```

```
kubectl describe job helloworld | less
.
.
Parallelism:    1
Completions:    2
Start Time:     Sun, 03 May 2020 02:17:13 +0200
Completed At:   Sun, 03 May 2020 02:17:21 +0200
Duration:       8s
Pods Statuses:  0 Running / 2 Succeeded / 0 Failed
.
.
```

```
kubectl delete job helloworld 
```

## Step 4:  you can tell how many job runs parallel (parallelism=2)

```
vi 2-job.yaml

apiVersion: batch/v1
kind: Job
metadata:
  name: helloworld
spec:
  completions: 2
  parallelism: 2
  template:
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["echo","Hello-K8s"]
      restartPolicy: Never
```
```
kubectl apply -f 2-job.yaml
kubectl describe job helloworld | less
kubectl delete job helloworld 
```

## Step 5: backoffLimit

fail for 2 times and will not create more pod
```
.
.
spec:
  backoffLimit: 2
.
.
``` 
```
kubectl describe job helloworld | less
kubectl delete job helloworld 
```

## Step 6: activeDeadLineSeconds

pod will run for max X secs
```
.
.
spec:
  activeDeadLineSeconds: 10
.
.
``` 

## Step 7: CRON JOB

file 2-cronjob.yaml
content

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: helloworld-cron
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: busybox
            image: busybox
            command: ["echo","Hello-K8s"]
          restartPolicy: Never
```

### 
```
kubectl apply -f  2-cronjob.yaml
kubectl delete CronJob helloworld-cron
```

### successfulJobHistoryLimit and dafulJobHistoryLimit

```
#default 3 success and 1 fail
successfulJobHistoryLimit 5
dafulJobHistoryLimit 3
```

### suspend job while investing issues
It will not stop job/pod which is alreday runniung but future job will not run

```
suspend: true
```

### patch command line way to change vakue of the fileds

```
kubectl patch cronjob helloworld-cron -p  '{"spec":{"suspend":false}}'
```

### concurrency

```
concurrencyPolicy allow/forbid/replace
```

### idempotency

### use case
mySQL backup
send email
souce code checkout




Ref:
- https://en.wikipedia.org/wiki/Cron
- * * * * * command to execute
```
# +------------- minute (0 - 59)
# ¦ +------------- hour (0 - 23)
# ¦ ¦ +------------- day of the month (1 - 31)
# ¦ ¦ ¦ +------------- month (1 - 12)
# ¦ ¦ ¦ ¦ +------------- day of the week (0 - 6) (Sunday to Saturday;
# ¦ ¦ ¦ ¦ ¦                                   7 is also Sunday on some systems)
# ¦ ¦ ¦ ¦ ¦
# ¦ ¦ ¦ ¦ ¦
# * * * * * command to execute
```