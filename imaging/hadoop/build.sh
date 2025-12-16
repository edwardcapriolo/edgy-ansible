./inc.sh
if [ ! -e "hadoop-3.4.2-src.tar.gz" ]; then
  curl https://dlcdn.apache.org/hadoop/common/hadoop-3.4.2/hadoop-3.4.2-src.tar.gz -O
fi

cat << EOF > Dockerfile
FROM ecapriolo/jre-17:0.0.1 AS hadoop-build
RUN apk add --no-cache gzip bash maven
# old protoc is neededhere
#RUN apk add protoc --repository=https://dl-cdn.alpinelinux.org/alpine/v3.19/main
#RUN apk add protoc
RUN apk add gcompat cmake make gcc g++  openssl-dev
RUN apk add zlib-dev
RUN apk add snappy-dev

RUN mkdir /build
COPY hadoop-3.4.2-src.tar.gz /build

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
WORKDIR /build
RUN cd /build
RUN tar -xf hadoop-3.4.2-src.tar.gz 
#alpine patch
COPY exception.c /build/hadoop-3.4.2-src/hadoop-common-project/hadoop-common/src/main/native/src/exception.c
RUN --mount=type=cache,target=/root/.m2 cd /build/hadoop-3.4.2-src/hadoop-common-project/hadoop-common && mvn package -Pnative -DskipTests -Dtar 
#-DprotocExecutable=/usr/bin/protoc
ENTRYPOINT ["hadoop checknative -a"]


EOF

DOCKER_BUILDKIT=1 docker build \
--target hadoop-build \
-t hadoop-build .

