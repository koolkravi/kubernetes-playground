# Install Docker  

### p.s. 
- docker-engine was renamed to docker-ce.
- Docker Engine on Ubuntu supports overlay2, aufs and btrfs storage drivers.
- Docker Engine uses the overlay2 storage driver by default
- Uninstall old versions

```
sudo apt-get remove docker docker-engine docker.io containerd runc
```

# Install using the repository

## SET UP THE REPOSITORY

```
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

## INSTALL DOCKER ENGINE

```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

## Verify that Docker Engine is installed

```
sudo docker run hello-world
```

### ps
- Docker Engine is installed and running. 
- The docker group is created but no users are added to it. You need to use sudo to run Docker commands
- check 
```
sudo docker version
sudo docker --version
sodo docker info
```

## Configure Docker to start on boot

```
sudo systemctl enable docker
systemctl start docker
```

## Manage Docker as a non-root user

```
getent group docker
sudo usermod -aG docker <your-user>
```

<<<<<<< HEAD
###Example: 

###Before
```
vagrant@ubuntuvm01:~$ getent group docker
docker:x:998:

vagrant@ubuntuvm01:~$ echo $USER
vagrant
```

###After
```
vagrant@ubuntuvm01:~$ sudo usermod -aG docker vagrant
vagrant@ubuntuvm01:~$ getent group docker
docker:x:998:vagrant
```


=======
>>>>>>> f81e8b6... added .md file
### ps : create the docker group and add your user

- Create the docker group
```
sudo groupadd docker
```

- Add your user to the docker group
```
sudo usermod -aG docker $USER
```

- activate the changes to groups
```
 newgrp docker 
```

## Uninstall Docker Engine

```
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
```

- Verify that you can run docker commands without sudo
```
docker run hello-world
```
