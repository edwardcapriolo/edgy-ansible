./inc.sh

cat << EOF > Dockerfile
FROM alpine:3.21.2
RUN apk add --no-cache openjdk17-jre-headless
ENTRYPOINT ["/usr/bin/java",  "-version"]
EOF

docker build \
--no-cache \
-t jre-17 .
