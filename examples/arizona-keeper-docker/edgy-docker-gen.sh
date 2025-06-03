#!/bin/bash
set -e
IMAGE_NAME=edgy-keeper

mkdir -p edgy-image-setup
cp -r ../../roles/arizona-keeper edgy-image-setup

cat <<EOF > Dockerfile
FROM alpine:3.21.3

RUN mkdir -p /etc/ansible/roles
ADD edgy-image-setup/arizona-keeper /etc/ansible/roles/arizona-keeper

RUN apk add ansible tar gzip

RUN ansible localhost -m import_role -a name=arizona-keeper --extra-vars "operation=install"

RUN apk add openjdk17-jre-headless

RUN apk del -r ansible python3 tar gzip

ENTRYPOINT ["sh /opt/arizona-keeper/apache-zookeeper-3.9.3-bin/bin/arizona-keeper-zkServer.sh", "start-foreground"]

#remove build stuff tar gz etc


EOF



docker build \
--progress=plain \
-t $IMAGE_NAME .

#--no-cache \ is super helpful to speed builds
