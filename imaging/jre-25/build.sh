#!/usr/bin/env bash
set -euo pipefail

ARM_CONTEXT="${ARM_CONTEXT:-colima}"
AMD_CONTEXT="${AMD_CONTEXT:-colima-x86}"
NO_CACHE="${NO_CACHE:-false}"
TARGETS=("jdk-25:" "jdk-25-gcompat:-gcompat" "jdk-25-devel:-devel" "jdk-25-cdevel:-cdevel")

if [ -f ./inc.sh ]; then
  . ./inc.sh
fi

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

build_one() {
  local target="$1"
  local variant="$2"
  local platform="$3"
  local context="$4"
  local suffix="$5"
  local cmd=(
    docker --context "$context" buildx build
    --platform "$platform"
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
