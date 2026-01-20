#!/bin/bash
set -e

if [ ! -e "hadoop-3.4.2-lean.tar.gz" ]; then
  curl https://dlcdn.apache.org/hadoop/common/hadoop-3.4.2/hadoop-3.4.2-lean.tar.gz -O
  tar -xf hadoop-3.4.2-lean.tar.gz
fi

#Work with src tar or git
B_SRC="git"
if [ ! -e "hd_src" ]; then
  if [ "$B_SRC" == "git" ]; then
    if [ ! -e "hadoop" ]; then
      git clone git@github.com:edwardcapriolo/hadoop.git hd_src
    fi
  else
    if [ ! -e "hadoop-3.4.2-src.tar.gz" ]; then
      curl https://dlcdn.apache.org/hadoop/common/hadoop-3.4.2/hadoop-3.4.2-src.tar.gz -O
    fi
    tar -xf hadoop-3.4.2-src.tar.gz
    mv hadoop-3.4.2-src hd_src
  fi
fi

rm -rf hadoop-3.4.2/share/doc/
rm -rf hadoop-3.4.2/share/hadoop/yarn/sources/
rm -rf hadoop-3.4.2/share/hadoop/client/hadoop-client-minicluster-3.4.2.jar
rm -rf hadoop-3.4.2/share/hadoop/common/hadoop-common-3.4.2-tests.jar
rm -rf hadoop-3.4.2/share/hadoop/common/sources/hadoop-common-3.4.2-test-sources.jar
rm -rf hadoop-3.4.2/lib/native/*
rm -rf hadoop-3.4.2/share/hadoop/yarn/hadoop-yarn-applications-catalog-webapp-3.4.2.war

#cp yarn-csi-pom.xml hd_src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-csi/pom.xml
cp build_and_deploy.sh hd_src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager

cd hd_src
mvn clean
cd ..


cat << EOF > base-dockerfile

FROM ecapriolo/jre-17:0.0.1 AS hadoop-base-build
RUN apk add --no-cache gzip bash maven
RUN apk add --no-cache gcompat cmake make gcc g++ openssl-dev zlib-dev snappy-dev bzip2-dev

RUN mkdir /build
COPY hd_src/ /build/hd_src
COPY hadoop-3.4.2 /build/hadoop-3.4.2

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
WORKDIR /build
RUN cd /build

RUN --mount=type=cache,target=/root/.m2 cd /build/hd_src/ && mvn install -Denforcer.skip=true -DskipTests --projects '!hadoop-tools/hadoop-azure,!hadoop-tools/hadoop-aws,!hadoop-cloud-storage-project/hadoop-gcp,!hadoop-client-modules/hadoop-client-minicluster,!hadoop-tools/hadoop-datajoin,!hadoop-tools/hadoop-benchmark'

EOF

DOCKER_BUILDKIT=1 docker build \
--target hadoop-base-build \
--file base-dockerfile \
-t hadoop-base-build .

