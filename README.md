# docker-build-scripts
My scripts in order to build custom images. The idea is to create images for 32bits docker.

Scripts are based on [docker/docker/contrib](https://github.com/docker/docker/tree/master/contrib) and the [arch wiki](https://wiki.archlinux.org/index.php/Docker).

The images corresponding to this scripts are:
* [nickcis/debian-32](https://hub.docker.com/r/nickcis/debian-32/)
* [nickcis/fedora-32](https://hub.docker.com/r/nickcis/fedora-32/)

The images were created on a 32bits arch linux, installing an old version of [docker-git](https://aur.archlinux.org/packages/docker-git/).

```
# docker version
Client version: 1.7.1
Client API version: 1.19
Go version (client): go1.4.2
Git commit (client): 786b29d
OS/Arch (client): linux/386
Server version: 1.7.1
Server API version: 1.19
Go version (server): go1.4.2
Git commit (server): 786b29d
OS/Arch (server): linux/386
```

**Note:** 
* `go` must be manually downgraded to `1.4.2`
* `docker` must be checkout to `786b29d` commit
* `docker` must be executed with the option `--exec-opt native.cgroupdriver=cgroupfs` (`/usr/lib/systemd/system/docker.service` must be modified)

## Fedora image (`mkimage-yum.sh`)

In order to build the fedora image `yum` has to be installed from [aur](https://aur.archlinux.org/packages/yum/). Base Fedora repositories were taken from the [`fedora-repos-22-1.noarch` package](http://fedora.c3sl.ufpr.br/fedora/linux/releases/22/Server/i386/os/Packages/f/fedora-repos-22-1.noarch.rpm), [`fedora-repos-23-1.noarch`](http://fedora.c3sl.ufpr.br/linux/releases/23/Server/i386/os/Packages/f/fedora-repos-23-1.noarch.rpm). Some special tweaks were needed:

```
$ cd /tmp
$ wget http://fedora.c3sl.ufpr.br/fedora/linux/releases/23/Server/i386/os/Packages/f/fedora-repos-23-1.noarch.rpm
$ rpm2cpio fedora-repos-23-1.noarch.rpm | cpio -idmv
$ sed -i 's/$releasever/23/g' /tmp/etc/yum.repos.d/*
$ sudo cp -r /tmp/etc/yum.repos.d /etc/yum/
$ sudo ln -s /etc/yum/yum.repos.d/ /etc/yum/repos.d
$ sudo cp -r /tmp/pki /etc/
$ sudo echo "i386" > /etc/yum/vars/basearch
$ sudo echo "23" > /etc/yum/vars/releasever
```

The script `mkimage-yum.sh` must be runned with `root` priviledges. (`name` is the docker tag)

```
# ./mkimage-yum.sh -h
mkimage-yum.sh [OPTIONS] <name> [repo name]
OPTIONS:
  -y <yumconf>  The path to the yum config to install packages from. The
                default is /etc/yum/yum.conf.
  -m <maintainer>  The maintainer to use
                default is "Me <me@mail.com>".
```

## Debian image (`mkimage-debian.sh`)

In order to build the debian image `debootstrap` has to be installed from [aur](https://aur.archlinux.org/packages/debootstrap/). No further tweaks are needed.

The script `mkimage-debian.sh` must be runned with `root` priviledges.

```
# ./mkimage-debian.sh -h
mkimage-debian.sh [OPTIONS] <name> [repo name]
  name: is the codename of the debian release
  repo name: is the name of the image repository for docker

OPTIONS:
  -m <maintainer>  The maintainer to use
                default is "Me <me@mail.com>".
```
