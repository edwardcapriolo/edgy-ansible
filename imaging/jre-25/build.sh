#!/usr/bin/env bash
set -euo pipefail

ARM_CONTEXT="${ARM_CONTEXT:-colima}"
AMD_CONTEXT="${AMD_CONTEXT:-colima-x86}"
ARM_COLIMA_PROFILE="${ARM_COLIMA_PROFILE:-default}"
AMD_COLIMA_PROFILE="${AMD_COLIMA_PROFILE:-x86}"
CHECK_COLIMA_PROFILES="${CHECK_COLIMA_PROFILES:-true}"
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
ripgrep \
openjdk17-jdk \
 && ln -sfn java-25-openjdk /usr/lib/jvm/forced-jvm \
 && ln -sfn java-25-openjdk /usr/lib/jvm/default-jvm
ENV JAVA_17_HOME=/usr/lib/jvm/java-17-openjdk
ENV JAVA_25_HOME=/usr/lib/jvm/java-25-openjdk
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk
ENV PATH=/usr/lib/jvm/java-25-openjdk/bin:\$PATH

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
