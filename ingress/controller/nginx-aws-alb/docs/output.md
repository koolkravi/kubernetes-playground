$ MINGW64 /d/my_data4/5.study_material/kubernetes-playground/ingress/controller/nginx-aws-alb (master)
$ git clone https://github.com/nginxinc/kubernetes-ingress/
Cloning into 'kubernetes-ingress'...
remote: Enumerating objects: 239, done.
remote: Counting objects: 100% (239/239), done.
remote: Compressing objects: 100% (205/205), done.
remote: Total 30304 (delta 73), reused 84 (delta 28), pack-reused 30065
Receiving objects: 100% (30304/30304), 40.98 MiB | 4.58 MiB/s, done.
Resolving deltas: 100% (16805/16805), done.
Updating files: 100% (3962/3962), done.

$ MINGW64 /d/my_data4/5.study_material/kubernetes-playground/ingress/controller/nginx-aws-alb (master)
$ cd kubernetes-ingress/deployments

kubernetes-ingress/deployments (master)
$ git checkout v1.9.1
Updating files: 100% (1639/1639), done.
Note: switching to 'v1.9.1'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at aa19bb45 Release 1.9.1

kubernetes-ingress/deployments ((v1.9.1))
$ kubectl apply -f common/ns-and-sa.yaml
namespace/nginx-ingress created
serviceaccount/nginx-ingress created

kubernetes-ingress/deployments ((v1.9.1))
$ kubectl apply -f rbac/rbac.yaml
clusterrole.rbac.authorization.k8s.io/nginx-ingress created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress created

kubernetes-ingress/deployments ((v1.9.1))
$ kubectl apply -f common/default-server-secret.yaml

secret/default-server-secret created

kubernetes-ingress/deployments ((v1.9.1))
$ kubectl apply -f common/nginx-config.yaml
configmap/nginx-config created

kubernetes-ingress/deployments ((v1.9.1))
$ kubectl apply -f deployment/nginx-ingress.yaml
deployment.apps/nginx-ingress created

kubernetes-ingress/deployments ((v1.9.1))
$ kubectl get pods --namespace=nginx-ingress
NAME                             READY   STATUS    RESTARTS   AGE
nginx-ingress-576565b59c-f9ff7   1/1     Running   0          2m45s

kubernetes-ingress/deployments ((v1.9.1))
$ kubectl apply -f service/loadbalancer-aws-elb.yaml
service/nginx-ingress created

kubernetes-ingress/deployments ((v1.9.1))
$ kubectl get svc --namespace=nginx-ingress
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)                      AGE
nginx-ingress   LoadBalancer   172.20.253.73   a08721931c2ff4e26a8be460fe7a2999-983588035.us-east-1.elb.amazonaws.com   80:32630/TCP,443:30247/TCP   11s

kubernetes-ingress/deployments ((v1.9.1))


$ kubectl get svc --namespace=nginx-ingress
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)                      AGE
nginx-ingress   LoadBalancer   172.20.253.73   a08721931c2ff4e26a8be460fe7a2999-983588035.us-east-1.elb.amazonaws.com   80:32630/TCP,443:30247/TCP   6m18s

kubectl get ing 
NAME            CLASS    HOSTS                                       ADDRESS   PORTS   AGE
micro-ingress   <none>   hostname.mydomain.com,apache.mydomain.com             80      8s

kubectl get svc
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
apache-svc     ClusterIP   172.20.166.220   <none>        80/TCP    7m25s
hostname-svc   ClusterIP   172.20.151.119   <none>        80/TCP    7m33s
kubernetes     ClusterIP   172.20.0.1       <none>        443/TCP   77m


$ kubectl describe ing  micro-ingress
Name:             micro-ingress
Namespace:        default
Address:
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host                   Path  Backends
  ----                   ----  --------
  hostname.mydomain.com
                            hostname-svc:80 (10.0.1.102:9376,10.0.1.235:9376)
  apache.mydomain.com
                            apache-svc:80 (10.0.1.104:80,10.0.1.200:80)
Annotations:
  kubectl.kubernetes.io/last-applied-configuration:  {"apiVersion":"extensions/v1beta1","kind":"Ingress","metadata":{"annotations":{},"name":"micro-ingress","namespace":"default"},"spec":{"rules":[{"host":"hostname.mydomain.com","http":{"paths":[{"backend":{"serviceName":"hostname-svc","servicePort":80}}]}},{"host":"apache.mydomain.com","http":{"paths":[{"backend":{"serviceName":"apache-svc","servicePort":80}}]}}]}}

Events:  <none>

$ curl -I http://a18556e2c56f34d9685ec11fb000b603-1631808824.us-east-1.elb.amazonaws.com/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0   153    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0HTTP/1.1 404 Not Found
Server: nginx/1.19.3
Date: Fri, 01 Jan 2021 00:41:18 GMT
Content-Type: text/html
Content-Length: 153
Connection: keep-alive

$ curl -I -H "Host: hostname.mydomain.com" http://a18556e2c56f34d9685ec11fb000b603-1631808824.us-east-1.elb.amazonaws.com/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0    29    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0HTTP/1.1 200 OK
Server: nginx/1.19.3
Date: Fri, 01 Jan 2021 00:55:32 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 29
Connection: keep-alive

$ curl -I -H "Host: apache.mydomain.com" http://a18556e2c56f34d9685ec11fb000b603-1631808824.us-east-1.elb.amazonaws.com/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0    45    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0HTTP/1.1 200 OK
Server: nginx/1.19.3
Date: Fri, 01 Jan 2021 00:56:00 GMT
Content-Type: text/html
Content-Length: 45
Connection: keep-alive
Last-Modified: Mon, 11 Jun 2007 18:53:14 GMT
ETag: "2d-432a5e4a73a80"
Accept-Ranges: bytes

