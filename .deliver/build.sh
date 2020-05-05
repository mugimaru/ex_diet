#!/bin/bash -e

#
# Build edeliver release in docker.
# Script arguments are forwareded to `mix edeliver build release` command.
#
# USAGE:
#   ./.deliver/build.sh
#
# ENV:
#    SSH_PUBLIC_KEY_PATH - path to ssh public key (default: $HOME/.ssh/id_rsa.pub).
#                          Required to build docker container accessible via ssh.
#

RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

DOCKERFILE=Dockerfile.build
IMAGE_NAME=ex_diet-build
PROD_SECRET_FILE="config/prod.secret.exs"
SSH_PUBLIC_KEY_PATH=${SSH_PUBLIC_KEY_PATH:-"$HOME/.ssh/id_rsa.pub"}

log()
{
  echo -e "${GREEN}[info] $1${NOCOLOR}"
}

error()
{
  echo -e "${RED}[error] $1${NOCOLOR}"
}

if [ ! -f "$SSH_PUBLIC_KEY_PATH" ]; then
  error "$SSH_PUBLIC_KEY_PATH is not found. Configure valid ssh public key path via SSH_PUBLIC_KEY_PATH env."
  exit 1
fi

if [ ! -f "$PROD_SECRET_FILE" ]; then
  error "Create $PROD_SECRET_FILE file before building an app."
  exit 1
fi

log "building docker container"
cp $SSH_PUBLIC_KEY_PATH .deliver/docker_build_ssh_key.pub
docker build --quiet --tag=$IMAGE_NAME -f $DOCKERFILE .

log "starting docker container"
BUILD_CONTAINER_ID="$(docker run -d -p 22:22 -P $IMAGE_NAME)"

trap 'log "removing docker container" && docker rm $BUILD_CONTAINER_ID --force' EXIT

log "building release"
mix edeliver build release "$@"