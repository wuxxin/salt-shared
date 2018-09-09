# docker

+ stop all container: docker stop $(docker ps -a -q)
+ remove all container: docker rm $(docker ps -a -q)
+ remove all docker volumes: docker volume ls -qf dangling=true | xargs -r docker volume rm
+ remove all docker images:  docker rmi $(docker images -q)