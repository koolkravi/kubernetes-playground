# kubernetes-playground

**Learn kubernetes**

# Reference:

## Helpful commands

**Get version**
```
kubectl version
kubectl version --short
```

**Get nodes status**
```
kubectl cluster-info
kubectl get nodes
kubectl get nodes -o wide
```

**Get component status**
```
kubectl get cs
```

**Copy kube config from master to host to use kubectl command**
```
mkdir $HOME/.kube
scp vagrant@10.0.0.5:/home/vagrant/.kube/config $HOME/.kube/config

note: 10.0.0.5 is IP of master node
```
