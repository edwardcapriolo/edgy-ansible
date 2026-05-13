
cat << EOF > Dockerfile
FROM jdk-25-cdevel AS trusted-opencode 

RUN apk add  --no-cache  go npm python3

#RUN apk add gcompat libstdc++ libgcc

RUN addgroup -S opencode && adduser -S -G opencode -h /opencode -D opencode
WORKDIR /opencode
USER opencode

COPY --from=oven/bun:alpine /usr/local/bin/bun /usr/local/bin/bun

#RUN curl -fsSL https://opencode.ai/install | VERSION=1.4.2 bash
RUN git clone https://github.com/anomalyco/opencode.git
RUN cd opencode
WORKDIR /opencode/opencode
#RUN bun init
RUN bun install
RUN bun run build
##RUN go mod download 
##RUN go build -o opencode ./cmd/opencode

# no web ui
#RUN go install github.com/opencode-ai/opencode@latest

USER root
RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder

WORKDIR /home/acoder
USER acoder

EOF

docker build \
-t trusted-opencode .
    
