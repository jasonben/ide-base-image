#!/usr/bin/env bash

set -e pipefail

# source .env

check_vars() {
  var_names=("$@")
  for var_name in "${var_names[@]}"; do
    [ -z "${!var_name}" ] && echo "$var_name is unset. Fix by copying .env.sample to .env" && var_unset=true
  done
  [ -n "$var_unset" ] && exit 1
  return 0
}

check_vars IDE_BASE_IMAGE

docker buildx use default

docker buildx build \
  --load \
  --file=Dockerfile \
  --build-arg IDE_BASE_IMAGE="$IDE_BASE_IMAGE" \
  -t "$IDE_BASE_IMAGE" .
