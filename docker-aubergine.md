# Docker
----
## How to Remove Docker Images, Containers and Volumes
by Aaron Kili | Published: June 21, 2018 | June 21, 2018  
https://www.tecmint.com/remove-docker-images-containers-and-volumes/

```docker
# listing all docker containers on your system
docker ps -a

# stop all containers
docker stop $(docker ps -a -q)

$ docker rm 0fd99ee0cb61		#remove a single container
$ docker rm 0fd99ee0cb61 0fd99ee0cb61   #remove multiple containers

$ docker stop 0fd99ee0cb61
$ docker rm -f 0fd99ee0cb61

$ docker rm -f 0fd99ee0cb61

You can remove containers using filters as well. For example to remove all exited containers, use this command.

$ docker rm $(docker ps -qa --filter "status=exited")


```

```docker
To stop and remove all containers, use the following commands.

$ docker stop $(docker ps -a -q)	#stop all containers
$ docker container prune		#interactively remove all stopped containers
OR
$ docker rm $(docker ps -qa)
```

----

## Docker: Remove all images and containers

https://techoverflow.net/2013/10/22/docker-remove-all-images-and-containers/

```bash
#!/bin/bash
# Delete all containers
docker rm $(docker ps -a -q)
# Delete all images
docker rmi $(docker images -q)
```

```docker
docker volume ls


```
