# docker

+ stop all container: docker stop $(docker ps -a -q)
+ remove all container: docker rm $(docker ps -a -q)
+ remove all docker volumes: docker volume ls -qf dangling=true | xargs -r docker volume rm
+ remove all docker images:  docker rmi $(docker images -q)

+ build patched docker
```
pull-lp-source docker.io
cd docker.io*
quilt import ../overlay2-on-zfs.patch
quilt import ../overlayfs-in-userns.patch
quilt push
current_version=$(head -1 debian/changelog | sed -r "s/[^(]+\(([^)]+)\).+/\1/g");
new_version=${current_version:0:-1}$(( ${current_version: -1} +1 ))overlayzfs;
debchange -v "$new_version" --distribution disco "experimental: overlay2-on-zfs.patch overlayfs-in-userns.patch"
dpkg-source -b .
cd ..
mkdir dockerbuild
backportpackage -b -U -w dockerbuild docker*overlayzfs*.dsc
cp dockerbuild/buildresult/docker.io*.deb /tmp
apt install /tmp/docker.io*.deb cgroup-lite
```
