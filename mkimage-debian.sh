#!/usr/bin/env bash
#
# Create a base Debian Docker image.

usage() {
    cat <<EOOPTS
$(basename $0) [OPTIONS] <name> [repo name]
  name: is the codename of the debian release
  repo name: is the name of the image repository for docker

OPTIONS:
  -m <maintainer>  The maintainer to use
                default is "Me <me@mail.com>".

EOOPTS
    exit 1
}

# option defaults
maintainer="Me <me@mail.com>"
while getopts ":m:h" opt; do
    case $opt in
        m)
            maintainer=$OPTARG
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            ;;
    esac
done
shift $((OPTIND - 1))
name=$1

if [[ -z $name ]]; then
    usage
fi

repo_name=$2
if [[ -z $repo_name ]]; then
    repo_name="debian"
fi

#--------------------

target=$(mktemp -d --tmpdir $(basename $0).XXXXXX)
tmp_build=$(mktemp -d --tmpdir $(basename $0).XXXXXX)

set -x

debootstrap "$name" "$target" http://http.debian.net/debian
tar --numeric-owner -c  -J -f "$tmp_build/debian-$name-docker.tar.xz" -C "$target" .

rm -rf "$target"

echo "FROM scratch" > "$tmp_build/Dockerfile"
echo "MAINTAINER $maintainer" >> "$tmp_build/Dockerfile"
echo "ADD debian-$name-docker.tar.xz /" >> "$tmp_build/Dockerfile"
echo "LABEL Vendor=\"Debian\"" >> "$tmp_build/Dockerfile"
echo "LABEL License=GPLv2" >> "$tmp_build/Dockerfile"
echo "" >> "$tmp_build/Dockerfile"
echo "# Volumes for systemd" >> "$tmp_build/Dockerfile"
echo "# VOLUME ["/run", "/tmp"]" >> "$tmp_build/Dockerfile"
echo "" >> "$tmp_build/Dockerfile"
echo "# Environment for systemd" >> "$tmp_build/Dockerfile"
echo "# ENV container=docker" >> "$tmp_build/Dockerfile"
echo "" >> "$tmp_build/Dockerfile"
echo "# For systemd usage this changes to /usr/sbin/init" >> "$tmp_build/Dockerfile"
echo "# Keeping it as /bin/bash for compatability with previous" >> "$tmp_build/Dockerfile"
echo "CMD [\"/bin/bash\"]" >> "$tmp_build/Dockerfile"

docker build -t "$repo_name:$name" "$tmp_build"

rm -rf "$tmp_build"

docker run "$repo_name:$name" echo "Works!"
