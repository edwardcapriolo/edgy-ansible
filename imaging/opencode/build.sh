
cat << EOF > Dockerfile
FROM jdk-25-cdevel AS trusted-opencode-build 

RUN apk --no-cache  add go npm python3
RUN apk --no-cache  add gcc g++ make
#RUN apk add gcompat libstdc++ libgcc

RUN addgroup -S opencode && adduser -S -G opencode -h /opencode -D opencode
WORKDIR /opencode
USER opencode

COPY --from=oven/bun:alpine /usr/local/bin/bun /usr/local/bin/bun

#RUN curl -fsSL https://opencode.ai/install | VERSION=1.4.2 bash
RUN git clone https://github.com/anomalyco/opencode.git
RUN cd opencode
WORKDIR /opencode/opencode
RUN bun install
RUN ./packages/opencode/script/build.ts --single

USER root
RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder

WORKDIR /home/acoder
USER acoder

FROM jdk-25-cdevel AS trusted-opencode

RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder

COPY --from=trusted-opencode-build /opencode/opencode/packages/opencode/dist/opencode-linux-x64/bin/opencode /usr/local/bin/opencode

WORKDIR /home/acoder                                                    
USER acoder


EOF

docker build \
--target trusted-opencode-build \
-t trusted-opencode-build .
    
docker build \
--target trusted-opencode \
-t trusted-opencode .
