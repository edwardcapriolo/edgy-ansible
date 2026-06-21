#!/usr/bin/env bash
set -euo pipefail

ARM_CONTEXT="${ARM_CONTEXT:-colima}"
AMD_CONTEXT="${AMD_CONTEXT:-colima-x86}"
NO_CACHE="${NO_CACHE:-false}"
TARGETS=("trusted-opencode-cdevel:-cdevel" "trusted-opencode-devel:-devel" "trusted-opencode-minimal:-minimal")

if [ -f ./inc.sh ]; then
  . ./inc.sh
fi

cat << EOF > Dockerfile
ARG JDK_CDEVEL_TAG=${JDK_VERSION}-cdevel
ARG JDK_DEVEL_TAG=${JDK_VERSION}-devel

FROM --platform=\$BUILDPLATFORM ${JDK_IMAGE_REPO}:\$JDK_CDEVEL_TAG AS trusted-opencode-build 
ARG TARGETARCH

  RUN apk --no-cache  add go npm python3
  RUN apk --no-cache  add gcc g++ make

  RUN addgroup -S opencode && adduser -S -G opencode -h /opencode -D opencode
  WORKDIR /opencode
  USER opencode

  COPY --from=oven/bun:alpine /usr/local/bin/bun /usr/local/bin/bun

  #RUN curl -fsSL https://opencode.ai/install | VERSION=1.4.2 bash
  RUN git clone https://github.com/anomalyco/opencode.git
  WORKDIR /opencode/opencode
  RUN git checkout ${OPENCODE_VERSION}
  RUN bun install
  RUN ./packages/opencode/script/build.ts --single
  RUN case "\$TARGETARCH" in \
        amd64) cp packages/opencode/dist/opencode-linux-x64/bin/opencode /tmp/opencode ;; \
        arm64) cp packages/opencode/dist/opencode-linux-arm64/bin/opencode /tmp/opencode ;; \
        *) echo "unsupported TARGETARCH=\$TARGETARCH" >&2; exit 1 ;; \
      esac

  USER root
  RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder
  WORKDIR /home/acoder
  USER acoder

FROM ${JDK_IMAGE_REPO}:\$JDK_CDEVEL_TAG AS trusted-opencode-cdevel
  RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder
  COPY --from=trusted-opencode-build /tmp/opencode /usr/local/bin/opencode
  WORKDIR /home/acoder                                                    
  USER acoder

FROM ${JDK_IMAGE_REPO}:\$JDK_DEVEL_TAG AS trusted-opencode-devel
  RUN apk add --no-cache libstdc++
  RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder
  COPY --from=trusted-opencode-build /tmp/opencode /usr/local/bin/opencode
  WORKDIR /home/acoder                                                                                                     
  USER acoder       

FROM alpine:3.23.4 AS trusted-opencode-minimal
  RUN apk add --no-cache libstdc++
  RUN addgroup -S acoder && adduser -S -G acoder -h /home/acoder -D acoder                                                 
  COPY --from=trusted-opencode-build /tmp/opencode /usr/local/bin/opencode
  WORKDIR /home/acoder                                                                                                     
  USER acoder    

EOF

build_one() {
  local target="$1"
  local variant="$2"
  local platform="$3"
  local context="$4"
  local suffix="$5"
  local cmd=(
    docker --context "$context" buildx build
    --platform "$platform"
    --build-arg "JDK_CDEVEL_TAG=$JDK_VERSION-cdevel-$suffix"
    --build-arg "JDK_DEVEL_TAG=$JDK_VERSION-devel-$suffix"
    --target "$target"
    -t "$IMAGE_REPO:$VERSION$variant-$suffix"
    -t "$IMAGE_REPO:latest$variant-$suffix"
    --load
    .
  )

  if [ "$NO_CACHE" = "true" ]; then
    cmd=(
      docker --context "$context" buildx build
      --platform "$platform"
      --no-cache
      --build-arg "JDK_CDEVEL_TAG=$JDK_VERSION-cdevel-$suffix"
      --build-arg "JDK_DEVEL_TAG=$JDK_VERSION-devel-$suffix"
      --target "$target"
      -t "$IMAGE_REPO:$VERSION$variant-$suffix"
      -t "$IMAGE_REPO:latest$variant-$suffix"
      --load
      .
    )
  fi

  "${cmd[@]}"
}

for entry in "${TARGETS[@]}"; do
  IFS=":" read -r target variant <<< "$entry"
  build_one "$target" "$variant" linux/arm64 "$ARM_CONTEXT" arm64
  build_one "$target" "$variant" linux/amd64 "$AMD_CONTEXT" amd64
done
