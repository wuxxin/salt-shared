# docker

## quick start

+ stop all container: docker stop $(docker ps -a -q)
+ remove all container: docker rm $(docker ps -a -q)
+ remove all docker images: docker rmi $(docker images -q)
+ remove all docker volumes (deletes all data):
    +  docker volume ls -qf dangling=true | xargs -r docker volume rm

## build and install custom docker


+ either using saltstack:
    + set pillar: "docker:origin"="custom"
    + execute `salt-call state.sls docker`

+ or using the shell:
    + execute: `build-custom-docker.sh $0 <target-archive-dir> [<version-postfix> <patch-file>*]`

