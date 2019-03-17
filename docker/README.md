# docker

+ stop all container: docker stop $(docker ps -a -q)
+ remove all container: docker rm $(docker ps -a -q)
+ remove all docker volumes: docker volume ls -qf dangling=true | xargs -r docker volume rm
+ remove all docker images:  docker rmi $(docker images -q)

+ build patched docker
```
apt-get install cowbuilder pbuilder devscripts ubuntu-dev-tools
export DEBSIGN_KEYID=991CEBDDE40966174E5C50399605D259C153AC6F
export DEBEMAIL=root@box

pull-lp-source docker.io
cd docker.io*
quilt import ../overlay2-on-zfs.patch
quilt import ../overlayfs-in-userns.patch
quilt push
cat > debian/changelog <<EOF
docker.io (18.09.2-0ubuntu2overlayzfs) disco; urgency=medium

  * Enable overlay2 storage driver with zfs as backing filesystem
    - this needs a custom zfs version (nodrevalidate)
  * pkg/archive: support overlayfs in user namespaces (ubuntu kernel only)
  * Experimental, use at your own risk!

 -- Felix Erkinger <wuxxin@gmail.com>  Thu, 14 Mar 2019 20:58:14 +0100

EOF
dpkg-source -b .
cd ..
mkdir dockerbuild
backportpackage -b -U -w dockerbuild docker*overlayzfs*.dsc
cp dockerbuild/buildresult/docker.io*.deb /tmp
apt install /tmp/docker.io*.deb cgroup-lite
```
