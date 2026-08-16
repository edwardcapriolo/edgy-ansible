#!/usr/bin/env bash
set -euo pipefail

ARM_CONTEXT="${ARM_CONTEXT:-colima}"
AMD_CONTEXT="${AMD_CONTEXT:-colima-x86}"
ARM_COLIMA_PROFILE="${ARM_COLIMA_PROFILE:-default}"
AMD_COLIMA_PROFILE="${AMD_COLIMA_PROFILE:-x86}"
CHECK_COLIMA_PROFILES="${CHECK_COLIMA_PROFILES:-true}"
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
  RUN apk add --no-cache \
        libstdc++ \
        docker \
        docker-cli \
        docker-cli-buildx \
        docker-rootless-extras \
        fuse-overlayfs \
        slirp4netns \
        shadow \
        shadow-subids \
        iptables \
        iproute2 \
   && addgroup -S acoder \
   && adduser -S -G acoder -h /home/acoder -D acoder \
   && echo 'acoder:100000:65536' >> /etc/subuid \
   && echo 'acoder:100000:65536' >> /etc/subgid
  COPY --from=trusted-opencode-build /tmp/opencode /usr/local/bin/opencode
  COPY start-rootless-docker /usr/local/bin/start-rootless-docker
  RUN chmod 755 /usr/local/bin/start-rootless-docker
  WORKDIR /home/acoder                                                    
  USER acoder

FROM ${JDK_IMAGE_REPO}:\$JDK_DEVEL_TAG AS trusted-opencode-devel
  RUN apk add --no-cache \
        libstdc++ \
        docker \
        docker-cli \
        docker-cli-buildx \
        docker-rootless-extras \
        fuse-overlayfs \
        slirp4netns \
        shadow \
        shadow-subids \
        iptables \
        iproute2 \
   && addgroup -S acoder \
   && adduser -S -G acoder -h /home/acoder -D acoder \
   && echo 'acoder:100000:65536' >> /etc/subuid \
   && echo 'acoder:100000:65536' >> /etc/subgid
  COPY --from=trusted-opencode-build /tmp/opencode /usr/local/bin/opencode
  COPY start-rootless-docker /usr/local/bin/start-rootless-docker
  RUN chmod 755 /usr/local/bin/start-rootless-docker
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

check_colima_profile() {
  local profile="$1"
  local arch="$2"

  if [ "$CHECK_COLIMA_PROFILES" != "true" ]; then
    return 0
  fi

  if ! command -v colima >/dev/null 2>&1; then
    echo "colima is not installed or not on PATH; set CHECK_COLIMA_PROFILES=false to skip this check" >&2
    exit 1
  fi

  local status
  if ! status="$(colima list 2>/dev/null | awk -v profile="$profile" 'NR > 1 && $1 == profile { print $2; found=1 } END { if (!found) exit 1 }')"; then
    echo "Colima profile '$profile' for $arch was not found" >&2
    echo "Set ${arch}_COLIMA_PROFILE to the correct profile name, or create it with: colima start --profile $profile" >&2
    exit 1
  fi

  if [ "$status" != "Running" ]; then
    echo "Colima profile '$profile' for $arch is $status; start it with: colima start --profile $profile" >&2
    exit 1
  fi
}

check_docker_context() {
  local context="$1"
  local arch="$2"

  if ! docker --context "$context" info >/dev/null 2>&1; then
    echo "Docker context '$context' for $arch is not reachable" >&2
    echo "Set ${arch}_CONTEXT to the correct Docker context name" >&2
    exit 1
  fi

  if ! docker --context "$context" buildx inspect >/dev/null 2>&1; then
    echo "Docker context '$context' for $arch is not usable with buildx" >&2
    echo "Check builders with: docker --context $context buildx ls" >&2
    exit 1
  fi
}

check_colima_profile "$ARM_COLIMA_PROFILE" ARM
check_colima_profile "$AMD_COLIMA_PROFILE" AMD
check_docker_context "$ARM_CONTEXT" ARM
check_docker_context "$AMD_CONTEXT" AMD

for entry in "${TARGETS[@]}"; do
  IFS=":" read -r target variant <<< "$entry"
  build_one "$target" "$variant" linux/arm64 "$ARM_CONTEXT" arm64
  build_one "$target" "$variant" linux/amd64 "$AMD_CONTEXT" amd64
done
