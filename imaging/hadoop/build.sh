./inc.sh
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


FROM ecapriolo/jre-17:0.0.1 AS tiny-hadoop

RUN apk add bash bzip2 openssl snappy zlib
RUN cd /usr/lib && ln -s libcrypto.so.3 libcrypto.so

RUN addgroup -S hdfs && adduser -S -G hdfs -H -D hdfs
RUN addgroup -S yarn && adduser -S -G yarn -H -D yarn
RUN addgroup -S auser && adduser -S -G auser -H -D auser

COPY --from=hadoop-build /build/hadoop-3.4.2-src/hadoop-common-project/hadoop-common/target/native/target/usr/local/lib/* /usr/local/lib
COPY hadoop-3.4.2 /opt/hadoop
RUN mkdir -p /opt/edgy/bin
COPY check_native.sh /opt/edgy/bin
RUN chmod 777 /opt/edgy/bin/check_native.sh
USER auser
ENTRYPOINT ["/opt/edgy/bin/check_native.sh"]


FROM tiny-hadoop AS tiny-yarn
USER root
RUN mkdir -p /yarn-root && chown yarn /yarn-root
USER yarn
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

