./inc.sh

cat << EOF > Dockerfile
FROM alpine:3.22.2
RUN cp /etc/apk/repositories /tmp/repositories
COPY repos /etc/apk/repositories

RUN apk add --no-cache openjdk25

RUN cp /tmp/repositories /etc/apk/repositories
ENTRYPOINT ["/usr/bin/java",  "-version"]
EOF

docker build \
--no-cache \
-t jdk-25 .
