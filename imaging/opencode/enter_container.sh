#!/usr/bin/env sh
set -eu

if [ -f ./inc.sh ]; then
  . ./inc.sh
fi

IMAGE_REPO="${IMAGE_REPO:-ecapriolo/trusted-opencode}"
IMAGE_VARIANT="${IMAGE_VARIANT:--devel}"
DETECTED_ARCH="$(docker info --format '{{.Architecture}}' 2>/dev/null || uname -m)"

case "${IMAGE_ARCH:-$DETECTED_ARCH}" in
  arm64|aarch64) IMAGE_ARCH="arm64" ;;
  amd64|x86_64) IMAGE_ARCH="amd64" ;;
  *) echo "unsupported IMAGE_ARCH=${IMAGE_ARCH:-$DETECTED_ARCH}" >&2; exit 1 ;;
esac

IMAGE_TAG="${IMAGE_TAG:-$IMAGE_REPO:latest$IMAGE_VARIANT-$IMAGE_ARCH}"

docker run -it \
  --device /dev/fuse \
  --device /dev/net/tun \
  --security-opt seccomp=unconfined \
  --security-opt apparmor=unconfined \
  --security-opt systempaths=unconfined \
  --sysctl net.ipv4.ip_forward=1 \
  --tmpfs /run \
  --tmpfs /tmp \
  -e TESTCONTAINERS_RYUK_DISABLED=true \
  --entrypoint /bin/bash \
  "$IMAGE_TAG"
