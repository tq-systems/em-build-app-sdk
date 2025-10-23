#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the app sdk project.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany.
# All rights reserved.
#
# Author: Christoph Krutz

set -e

# Set default uid/gid
CURRENT_UID="$(id -u)"
CURRENT_GID="$(id -g)"

# The docker images may have build with another user (uid/gid)
if [ -n "$DOCKER_UID" ]; then
	CURRENT_UID="$DOCKER_UID"
fi
if [ -n "$DOCKER_GID" ]; then
	CURRENT_UID="$DOCKER_GID"
fi

CURRENT_PATH="$(pwd)"
HOME_PATH="/home/tqemci"

# Some directories will be created as root during the mount, if they don't exist
if [ ! -d "$TQEM_BASE_DEPLOY_PATH" ]; then
	mkdir -p "$TQEM_BASE_DEPLOY_PATH"
fi
if [ ! -d "$TQEM_APPS_CACHE_PATH" ]; then
	mkdir -p "$TQEM_APPS_CACHE_PATH"
fi


# Build docker mount arguments conditionally
MOUNT_ARGS=()
[ -d "$HOME/.ssh" ] && MOUNT_ARGS+=(-v "$HOME/.ssh:$HOME_PATH/.ssh")
[ -f "$HOME/.gitconfig" ] && MOUNT_ARGS+=(-v "$HOME/.gitconfig:$HOME_PATH/.gitconfig")
[ -d "$HOME/.docker" ] && MOUNT_ARGS+=(-v "$HOME/.docker:$HOME_PATH/.docker")
[ -d "$HOME/.cache" ] && MOUNT_ARGS+=(-v "$HOME/.cache:$HOME_PATH/.cache")
[ -n "$NPM_TOKEN" ] && MOUNT_ARGS+=(-e NPM_TOKEN)

# Check if stdin is a terminal
DOCKER_TERMINAL="-i"
if [ -t 1 ]; then
    DOCKER_TERMINAL="-it"
fi

# Pass environment variables starting with TQEM_ to the container
# shellcheck disable=SC2046
exec docker run "$DOCKER_TERMINAL" --init \
	--security-opt seccomp=unconfined \
	$(env | grep ^TQEM_ | sed 's/^/-e /') \
	-u "$CURRENT_UID:$CURRENT_GID" \
	"${MOUNT_ARGS[@]}" \
	-v "$TQEM_BASE_DEPLOY_PATH:$TQEM_BASE_DEPLOY_PATH" \
	-v "$TQEM_APPS_CACHE_PATH:$TQEM_APPS_CACHE_PATH" \
	-v "$CURRENT_PATH:$CURRENT_PATH" \
	-w "$CURRENT_PATH" \
	--rm \
	"$@"
