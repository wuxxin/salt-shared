# docker

see defaults.jinja for options

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

+ or using the shell, execute:
    + `build-custom-docker.sh <target-dir> [--source distro] [--dest distro] [--version-postfix <postfix>] [<patch-file>*]`
    + add to a custom apt repository, install from there

### patches applied

+ overlay2-on-zfs.patch
    + custom patch to support overlayfs on zfs in docker

+ overlayfs-in-userns.patch
    + https://github.com/moby/moby/pull/38038
    + https://github.com/moby/moby/commit/de640c9f4932d851316a0a72470c4d3446f6f5ac
    + https://github.com/moby/moby/issues/35245
    + Can't pull docker images containing device nodes when running docker inside user namespace #35245
    + modified patch to make a clean apply (pull-request -> patch)

### errors still occuring

+ docker pull kamax/mxisd
```
failed to register layer: Error processing tar file(exit status 1): replaceDirWithOverlayOpaque("/e
tc/terminfo") failed: createDirWithOverlayOpaque("/etc/rdwoo822984297") failed: failed to mkdir /et
c/rdwoo822984297/m/d: mkdir /etc/rdwoo822984297/m/d: input/output error
```
    + https://github.com/moby/moby/blob/6359da4afa34dbfa1d28eca51875e58ca19df9ec/pkg/archive/archive_linux.go#L252

### patches already applied upstream

+ fix-overlay2-untar-in-userns.patch
    + https://github.com/moby/moby/pull/35794
    + Fix overlay2 storage driver inside a user namespace #35794
    + https://github.com/moby/moby/commit/0862014431d40174a7b4e614ddcc0ee6e13ad570

### patches not applied
+ https://github.com/moby/moby/issues/38289
    + pkg/archive: fix TestTarUntarWithXattr failure on recent kernel #38292
    + https://github.com/moby/moby/pull/38292

+ https://github.com/moby/moby/issues/37970
    + https://github.com/moby/moby/pull/37993
        +  overlay2: use index=off if possible (fix EBUSY on mount) #37993 
    + https://github.com/docker/engine/pull/84
        + [18.09 backport] overlay2: use index=off if possible (fix EBUSY on mount) #84

