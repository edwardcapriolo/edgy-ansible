
cat << EOF > Dockerfile
FROM jdk-25-cdevel AS trusted-opencode 

RUN apk add gcompat libstdc++ libgcc

RUN addgroup -S opencode && adduser -S -G opencode -h /opencode -D opencode
WORKDIR /opencode
USER opencode

RUN curl -fsSL https://opencode.ai/install | VERSION=1.4.2 bash

USER root
RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder

WORKDIR /home/acoder
USER acoder

EOF

docker build \
--no-cache \
-t trusted-opencode .
    
