./inc.sh

cat << EOF > Dockerfile
FROM alpine:3.22.2 AS jdk-25
RUN cp /etc/apk/repositories /tmp/repositories
COPY repos /etc/apk/repositories

RUN apk add --no-cache openjdk25

RUN cp /tmp/repositories /etc/apk/repositories
ENTRYPOINT ["/usr/bin/java",  "-version"]

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

docker build \
--no-cache \
-t jdk-25 .

docker build \
--no-cache \
-t jdk-25-devel .

docker build \
--no-cache \
-t jdk-25-cdevel .
    
