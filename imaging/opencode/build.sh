
cat << EOF > Dockerfile
FROM ecapriolo/jdk-25-cdevel:0.0.3 AS trusted-opencode-build 

  RUN apk --no-cache  add go npm python3
  RUN apk --no-cache  add gcc g++ make

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

FROM ecapriolo/jdk-25-cdevel:0.0.3 AS trusted-opencode-cdevel
  RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder
  COPY --from=trusted-opencode-build /opencode/opencode/packages/opencode/dist/opencode-linux-x64/bin/opencode /usr/local/bin/opencode
  WORKDIR /home/acoder                                                    
  USER acoder

FROM ecapriolo/jdk-25-devel:0.0.3 AS trusted-opencode-devel
  RUN apk add --no-cache libstdc++
  RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder
  COPY --from=trusted-opencode-build /opencode/opencode/packages/opencode/dist/opencode-linux-x64/bin/opencode /usr/local/bin/opencode
  WORKDIR /home/acoder                                                                                                     
  USER acoder       

FROM alpine:3.23.4 AS trusted-opencode-minimal
  RUN apk add --no-cache libstdc++
  RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder                                                 
  COPY --from=trusted-opencode-build /opencode/opencode/packages/opencode/dist/opencode-linux-x64/bin/opencode /usr/local/bin/opencode
  WORKDIR /home/acoder                                                                                                     
  USER acoder    

EOF

docker build \
--target trusted-opencode-build \
-t trusted-opencode-build .
    
docker build \
--target trusted-opencode-cdevel \
-t trusted-opencode-cdevel .

docker build \
--target trusted-opencode-devel \
-t trusted-opencode-devel .

docker build \
--target trusted-opencode-minimal \
-t trusted-opencode-minimal . 
