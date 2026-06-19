./inc.sh

cat << EOF > Dockerfile
FROM alpine:3.23.4 AS jdk-25
RUN cp /etc/apk/repositories /tmp/repositories
COPY repos /etc/apk/repositories

RUN apk update --no-cache && apk upgrade --no-cache 
RUN apk add --no-cache openjdk25

RUN cp /tmp/repositories /etc/apk/repositories
ENTRYPOINT ["/usr/bin/java",  "-version"]

FROM jdk-25 AS jdk-25-gcompat

  RUN apk add --no-cache gcompat libstdc++

FROM jdk-25 AS jdk-25-devel

RUN apk add --no-cache maven \
jq \
git \
curl \
bash \
gpg \
coreutils \
findutils \
ripgrep

FROM jdk-25-devel AS jdk-25-cdevel

RUN apk add llvm \
clang \
lld \
coreutils \
clang20-libclang \
make

EOF

docker buildx build \
--platform linux/amd64,linux/arm64 \
--no-cache \
--target jdk-25 \
-t jdk-25 --load .

docker buildx build \
--platform linux/amd64,linux/arm64 \
--no-cache \
--target jdk-25-gcompat \
-t jdk-25-gcompat --load .

#docker build \
#--no-cache \
#--target jdk-25-gcompat \
#-t jdk-25-gcompat . 

#docker build \
#--no-cache \
#--target jdk-25-devel \
#-t jdk-25-devel .

#docker build \
#--no-cache \
#--target jdk-25-cdevel \
#-t jdk-25-cdevel .
    
