#!/bin/bash
set -e

#./inc.sh
if [ ! -e "hadoop-3.4.2-src.tar.gz" ]; then
  curl https://dlcdn.apache.org/hadoop/common/hadoop-3.4.2/hadoop-3.4.2-src.tar.gz -O
fi

if [ ! -e "hadoop-3.4.2-lean.tar.gz" ]; then
 curl https://dlcdn.apache.org/hadoop/common/hadoop-3.4.2/hadoop-3.4.2-lean.tar.gz -O
 tar -xf hadoop-3.4.2-lean.tar.gz
fi

rm -rf hadoop-3.4.2/share/doc/
rm -rf hadoop-3.4.2/share/hadoop/yarn/sources/

#rm -rf hadoop-3.4.2/share/hadoop/yarn/timelineservice/
rm -rf hadoop-3.4.2/share/hadoop/client/hadoop-client-minicluster-3.4.2.jar
rm -rf hadoop-3.4.2/share/hadoop/common/hadoop-common-3.4.2-tests.jar
rm -rf hadoop-3.4.2/share/hadoop/common/sources/hadoop-common-3.4.2-test-sources.jar
rm -rf hadoop-3.4.2/lib/native/*
rm -rf hadoop-3.4.2/share/hadoop/yarn/hadoop-yarn-applications-catalog-webapp-3.4.2.war

cat << EOF > Dockerfile
FROM ecapriolo/jre-17:0.0.1 AS hadoop-build
RUN apk add --no-cache gzip bash maven
# old protoc is neededhere
#RUN apk add protoc --repository=https://dl-cdn.alpinelinux.org/alpine/v3.19/main
#RUN apk add protoc

RUN apk add gcompat cmake make gcc g++ openssl-dev zlib-dev snappy-dev bzip2-dev

COPY build_old_protoc.sh /build_old_protoc.sh
RUN chmod 777 /build_old_protoc.sh && /build_old_protoc.sh

RUN mkdir /build
COPY hadoop-3.4.2-src.tar.gz /build
COPY hadoop-3.4.2 /build
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
WORKDIR /build
RUN cd /build
RUN tar -xf hadoop-3.4.2-src.tar.gz 
#alpine patch
COPY exception.c /build/hadoop-3.4.2-src/hadoop-common-project/hadoop-common/src/main/native/src/exception.c
RUN sed -ri 's/^(.*JniBasedUnixGroupsNetgroupMapping.c)/#\1/g' /build/hadoop-3.4.2-src/hadoop-common-project/hadoop-common/src/CMakeLists.txt
RUN --mount=type=cache,target=/root/.m2 cd /build/hadoop-3.4.2-src/hadoop-common-project/hadoop-common && mvn package -Pnative -DskipTests -Dtar 
RUN cp /build/hadoop-3.4.2-src/hadoop-common-project/hadoop-common/target/native/target/usr/local/lib/* /usr/local/lib
#-DprotocExecutable=/usr/bin/protoc

#Did all this to get limit.h.
#linux/limits.h != limits.h https://stackoverflow.com/questions/73168335/difference-between-include-limits-h-and-inlcude-linux-limits-h
#you learn something new every day
RUN apk add --no-cache libmagic musl-dev file-dev file linux-headers
RUN --mount=type=cache,target=/root/.m2 cd /build/hadoop-3.4.2-src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager \
&& mvn package -Pnative -Dmaven.skip.test=true -DskipTests -Dtar

RUN cp /build/hadoop-3.4.2-src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager/target/native/libcontainer.a /usr/local/lib

FROM ecapriolo/jre-17:0.0.1 AS tiny-hadoop

  #https://issues.apache.org/jira/browse/HADOOP-19758
  RUN apk add --no-cache bash bzip2 openssl snappy zlib ncurses
  RUN cd /usr/lib && ln -s libcrypto.so.3 libcrypto.so

  RUN addgroup -S hadoop
  RUN addgroup -S hdfs && adduser -S -G hdfs -H -D hdfs
  RUN addgroup -S yarn && adduser -S -G yarn -H -D yarn
  RUN addgroup -S auser && adduser -S -G auser -H -D auser

  COPY --from=hadoop-build /build/hadoop-3.4.2-src/hadoop-common-project/hadoop-common/target/native/target/usr/local/lib/* /usr/local/lib

  COPY --from=hadoop-build /build/hadoop-3.4.2-src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager/target/native/target/usr/local/bin/ /usr/local/bin
  RUN mkdir -p /usr/local/etc/hadoop
  COPY container-executor.cfg /usr/local/etc/hadoop/container-executor.cfg
  RUN chown root:root /usr/local/etc/hadoop/container-executor.cfg
  RUN chmod 6050 /usr/local/bin/container-executor
  RUN chgrp hadoop /usr/local/bin/container-executor


  COPY hadoop-3.4.2 /opt/hadoop
  RUN mkdir -p /opt/edgy/bin
  COPY check_native.sh /opt/edgy/bin
  RUN chmod 777 /opt/edgy/bin/check_native.sh
  COPY special.sh /opt/edgy/bin/special.sh
  RUN chmod 777 /opt/edgy/bin/special.sh

  #COPY 99-hdfs-profile.sh /etc/profile.d/99-hdfs-profile.sh
  #RUN echo "export PATH=\$PATH:/opt/hadoop/bin" >> /etc/profile

  COPY compositions /compositions
  RUN mkdir -p /auser-root && chown auser /auser-root
  USER auser
  ENTRYPOINT ["/opt/edgy/bin/check_native.sh"]


FROM tiny-hadoop AS tiny-yarn
USER root
RUN mkdir -p /yarn-root && chown yarn /yarn-root

RUN chmod 6050 /usr/local/bin/container-executor
USER yarn:hadoop
ENTRYPOINT ["/opt/hadoop/bin/yarn"]


FROM tiny-hadoop AS tiny-hdfs
USER root
RUN mkdir -p /hdfs-root && chown hdfs /hdfs-root
USER hdfs
ENTRYPOINT ["/opt/hadoop/bin/hdfs"]

EOF

DOCKER_BUILDKIT=1 docker build \
--target hadoop-build \
-t hadoop-build .

docker build \
--target tiny-hadoop \
-t tiny-hadoop .

docker build \
--target tiny-yarn \
-t tiny-yarn .

docker build \
--target tiny-hdfs \
-t tiny-hdfs .

