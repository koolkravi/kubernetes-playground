# Installing the NFS server on ubuntu 

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

## Install NSF Server

### Step 1: 
```
vagrant ssh k-master
```

```
sudo apt update
sudo apt install nfs-kernel-server

output:
Job for nfs-server.service canceled.

Creating config file /etc/exports with new version
Creating config file /etc/default/nfs-kernel-server with new version
```

- Once the installation is completed, the NFS services will start automatically
```
systemctl status  nfs-server.service
```

- By default, on Ubuntu 18.04 NFS version 2 is disabled. Versions 3 and 4 are enabled
- NFSv2 is pretty old now, and there is no reason to enable it
- NFS server configuration options are set in /etc/default/nfs-kernel-server and /etc/default/nfs-common files

```
vagrant@k-master:~$ sudo cat /proc/fs/nfsd/versions
-2 +3 +4 +4.1 +4.2
```

### Step 2:  Creating the file systems

```
sudo mkdir -p /srv/nfs4/backups
sudo mkdir -p /srv/nfs4/www
```

- We’re going to share two directories (/var/www and /opt/backups)
- The /var/www/ is owned by the user and group www-data
- /opt/backups is owned by root

```
sudo mkdir -p /var/www
sudo mkdir -p /opt/backups
```

```
vagrant@k-master:~$ ll /var/www
total 8
drwxr-xr-x  2 root root 4096 May  4 20:47 ./
drwxr-xr-x 14 root root 4096 May  4 20:47 ../
```

```
vagrant@k-master:~$ sudo chown vagrant:www-data /var/www
```

```
vagrant@k-master:~$ ll /var/www
total 8
drwxr-xr-x  2 vagrant www-data 4096 May  4 20:47 ./
drwxr-xr-x 14 root    root     4096 May  4 20:47 ../

vagrant@k-master:~$ ll /opt/backups/
total 8
drwxr-xr-x 2 root root 4096 May  4 20:46 ./
drwxr-xr-x 6 root root 4096 May  4 20:46 ../
```


### Step 3: Mount the actual directories:

```
vagrant@k-master:~$ sudo mount --bind /opt/backups /srv/nfs4/backups/
vagrant@k-master:~$ sudo mount --bind /var/www /srv/nfs4/www/
```

- To make the bind mounts permanent, open the /etc/fstab file and add below

```
vi /etc/fstab

/opt/backups /srv/nfs4/backups  none   bind   0   0
/var/www     /srv/nfs4/www      none   bind   0   0
```

### step 4: Exporting the file systems
- we need to export the www and backups directories and allow access only from clients on the 10.0.0.0/24 network
```
sudo vi /etc/exports

/srv/nfs4         10.0.0.0/24(rw,sync,no_subtree_check,crossmnt,fsid=0)
/srv/nfs4/backups 10.0.0.0/24(ro,sync,no_subtree_check) 10.0.0.7(rw,sync,no_subtree_check)
/srv/nfs4/www     10.0.0.6(rw,sync,no_subtree_check)
```

- export the shares
```
sudo exportfs -ra
```
- You need to run the command above each time you modify the /etc/exports file
- man exports

- To view the current active exports and their state
```
vagrant@k-master:~$ sudo exportfs -v
/srv/nfs4/backups
                10.0.0.7(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
/srv/nfs4/www   10.0.0.6(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
/srv/nfs4       10.0.0.0/24(rw,wdelay,crossmnt,root_squash,no_subtree_check,fsid=0,sec=sys,rw,secure,root_squash,no_all_squash)
/srv/nfs4/backups
                10.0.0.0/24(ro,wdelay,root_squash,no_subtree_check,sec=sys,ro,secure,root_squash,no_all_squash)
```

## Firewall configuration
```
sudo ufw allow from 10.0.0.0/24 to any port nfs
```
- to verify

```
sudo ufw enable
vagrant@k-master:~$ sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
2049                       ALLOW       10.0.0.0/24

```

##  Set Up the NFS Clients
NFS server is setup and shares are exported the next step configure the clients and mount the remote file systems.

## Installing the NFS client (k-worker01, k-worker02)
- On the client machines we need to install only the tools required to mount a remote NFS file systems
### 
```
sudo apt update
sudo apt install nfs-common
```
### Mounting file systems
- Create two new directories for the mount points
- read and write access to the /srv/nfs4/www file system and read only access to the /srv/nfs4/backups file system.

```
sudo mkdir -p /backups
sudo mkdir -p /srv/www
```

- Mounting file systems
```
sudo mount -t nfs -o vers=4 10.0.0.5:/backups /backups
sudo mount -t nfs -o vers=4 10.0.0.5:/www /srv/www
``
- 10.0.0.5   is ip of nfs server
- When mounting an NFSv4 filesystem, you need to ommit the NFS root directory, so instead of /srv/nfs4/backups you need to use /backups

- verify

```
vagrant@k-worker01:~$ df -h
Filesystem                    Size  Used Avail Use% Mounted on
udev                          463M     0  463M   0% /dev
tmpfs                          99M  6.0M   93M   6% /run
/dev/mapper/vagrant--vg-root   62G  3.1G   56G   6% /
tmpfs                         493M     0  493M   0% /dev/shm
tmpfs                         5.0M     0  5.0M   0% /run/lock
tmpfs                         493M     0  493M   0% /sys/fs/cgroup
vagrant                       270G  178G   93G  66% /vagrant
tmpfs                          99M     0   99M   0% /run/user/1000
10.0.0.5:/backups              62G  3.8G   55G   7% /backups
10.0.0.5:/www                  62G  3.8G   55G   7% /srv/www
```

- To make the mounts permanent on reboot, open the /etc/fstab file and add below
```
sudo nano /etc/fstab

10.0.0.5:/backups /backups   nfs   defaults,timeo=900,retrans=5,_netdev	0 0
10.0.0.5:/www /srv/www       nfs   defaults,timeo=900,retrans=5,_netdev	0 0
```

- man nfs
- Another option to mount the remote file systems is to use either the autofs tool or to create a systemd unit

## Testing NFS Access

### create a test file to the /backups directory

```
vagrant@k-worker01:~$ touch /backups/test.txt

out:
touch: cannot touch '/backups/test.txt': Read-only file system
```
- The /backup file system is exported as read-only and as expected you will see a Permission denied error message

### create a test file to the /srv/www directory as a root using the sudo command

```
vagrant@k-worker01:~$ sudo touch /srv/www/test.txt

out: 
touch: cannot touch '/srv/www/test.txt': Permission denied
```
- Again, you will see Permission denied message

### test to create a file as user www-data

```
#sudo -u www-data touch /srv/www/test.txt
```

```
#add user vagrant to group www-data
sudo usermod -a -G www-data vagrant
vagrant@k-worker02:~$ touch /srv/www/test.txt
```

### verify it list the files in the /srv/www directory
```
vagrant@k-worker02:~$ ls -la /srv/www/
total 8
drwxr-xr-x 2 vagrant www-data 4096 May  4 23:13 .
drwxr-xr-x 3 root    root     4096 May  4 22:52 ..
-rw-rw-r-- 1 vagrant vagrant     0 May  4 23:13 test.txt

vagrant@k-worker01:~$ ll -la /srv/www/
total 8
drwxr-xr-x 2 vagrant www-data 4096 May  4 23:13 ./
drwxr-xr-x 3 root    root     4096 May  4 22:51 ../
-rw-rw-r-- 1 vagrant vagrant     0 May  4 23:13 test.txt

vagrant@k-master:~$ ls -la /var/www/
total 8
drwxr-xr-x  2 vagrant www-data 4096 May  4 23:13 .
drwxr-xr-x 14 root    root     4096 May  4 20:47 ..
-rw-rw-r--  1 vagrant vagrant     0 May  4 23:13 test.txt

```

## Unmounting NFS File System

```
sudo umount /backups
```
- If the mount point is defined in the /etc/fstab file, make sure you remove the line or comment it out by adding # at the beginning of the line


## Ref :
- https://linuxize.com/post/how-to-install-and-configure-an-nfs-server-on-ubuntu-18-04/
- 
