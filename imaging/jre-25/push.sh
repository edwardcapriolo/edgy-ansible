#!/usr/bin/env bash
set -euo pipefail

ARM_CONTEXT="${ARM_CONTEXT:-colima}"
AMD_CONTEXT="${AMD_CONTEXT:-colima-x86}"
TARGETS=("jdk-25:" "jdk-25-gcompat:-gcompat" "jdk-25-devel:-devel" "jdk-25-cdevel:-cdevel")

if [ -f ./inc.sh ]; then
  . ./inc.sh
fi

push_arch_tag() {
  local variant="$1"
  local arch="$2"
  local context="$3"

  docker --context "$context" push "$IMAGE_REPO:$VERSION$variant-$arch"
  docker --context "$context" push "$IMAGE_REPO:latest$variant-$arch"
}

push_manifest() {
  local variant="$1"
  local tag="$2"

  docker buildx imagetools create -t "$IMAGE_REPO:$tag$variant" \
    "$IMAGE_REPO:$tag$variant-amd64" \
    "$IMAGE_REPO:$tag$variant-arm64"
}

for entry in "${TARGETS[@]}"; do
  IFS=":" read -r target variant <<< "$entry"
  push_arch_tag "$variant" arm64 "$ARM_CONTEXT"
  push_arch_tag "$variant" amd64 "$AMD_CONTEXT"
  push_manifest "$variant" "$VERSION"
  push_manifest "$variant" latest
done
