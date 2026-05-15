#!/bin/bash
# SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
#
# More license information can be found in the root folder.
# This file is part of the app sdk project.
#
# Copyright (c) 2025 TQ-Systems GmbH <license@tq-group.com>, D-82229 Seefeld, Germany.
# All rights reserved.

# Starts a local frontend development environment by cloning or updating
# the UI-Server, wiring an app frontend into it, and running both dev
# servers. Reads its configuration from the TQEM_* environment variables
# exported by environment.mk.

set -euo pipefail

# --check exits after validating required environment variables, without
# touching the filesystem or starting any servers. Used by 'make
# frontend-dev-check' for a CI smoke test.
CHECK_ONLY=0
if [ "${1:-}" = "--check" ]; then
    CHECK_ONLY=1
fi

# Check prerequisites (skipped in --check mode, which is meant to run without node/yarn)
if [ "${CHECK_ONLY}" -eq 0 ]; then
    if ! command -v node >/dev/null 2>&1; then
        echo "ERROR: node is not installed. Please install Node.js 22 or later." >&2
        exit 1
    fi
    NODE_MAJOR=$(node -p "process.versions.node.split('.')[0]")
    if [ "${NODE_MAJOR}" -lt 22 ]; then
        echo "ERROR: Node.js 22 or later is required (found $(node --version))." >&2
        exit 1
    fi
    if ! command -v yarn >/dev/null 2>&1; then
        echo "ERROR: yarn is not installed. Please install yarn via 'corepack enable'." >&2
        exit 1
    fi
fi

UI_SERVER_REPO="${TQEM_UI_SERVER_REPO:-}"
UI_SERVER_VERSION="${TQEM_UI_SERVER_VERSION:-}"
UI_SERVER_DIR="${TQEM_UI_SERVER_DIR:-}"
APP_ID="${TQEM_FRONTEND_APP_ID:-}"
APP_FRONTEND_DIR="${TQEM_FRONTEND_APP_DIR:-}"
BRANDING="${TQEM_BRANDING:-default}"
TARGET_URL="${TQEM_TARGET_URL:-}"
DEV_HOST="${TQEM_FRONTEND_DEV_HOST:-0.0.0.0}"

if [ -z "${APP_ID}" ]; then
    echo "ERROR: TQEM_FRONTEND_APP_ID must be set (e.g. device-settings)" >&2
    exit 1
fi
if [ -z "${APP_FRONTEND_DIR}" ]; then
    echo "ERROR: TQEM_FRONTEND_APP_DIR must be set (path to app frontend/ directory)" >&2
    exit 1
fi
if [ -z "${TARGET_URL}" ]; then
    echo "ERROR: TQEM_TARGET_URL must be set (URL of a running Energy Manager gateway)" >&2
    exit 1
fi
if [ -z "${UI_SERVER_REPO}" ] || [ -z "${UI_SERVER_VERSION}" ] || [ -z "${UI_SERVER_DIR}" ]; then
    echo "ERROR: TQEM_UI_SERVER_REPO, TQEM_UI_SERVER_VERSION and TQEM_UI_SERVER_DIR must be set" >&2
    exit 1
fi

if [ "${CHECK_ONLY}" -eq 1 ]; then
    echo "frontend-dev: configuration valid"
    exit 0
fi

# Resolve relative paths to absolute
[[ "${UI_SERVER_DIR}" = /* ]] || UI_SERVER_DIR="${PWD}/${UI_SERVER_DIR}"
[[ "${APP_FRONTEND_DIR}" = /* ]] || APP_FRONTEND_DIR="${PWD}/${APP_FRONTEND_DIR}"

UI_FRONTEND_DIR="${UI_SERVER_DIR}/frontend"
APPS_DIR="${UI_FRONTEND_DIR}/apps"

# Clone or pull UI-Server. Existing checkouts are reused, but we refuse to
# overwrite a different remote URL or to discard local changes silently.
if [ ! -d "${UI_SERVER_DIR}/.git" ]; then
    git clone "${UI_SERVER_REPO}" "${UI_SERVER_DIR}"
else
    existing_remote=$(git -C "${UI_SERVER_DIR}" remote get-url origin 2>/dev/null || true)
    if [ -n "${existing_remote}" ] && [ "${existing_remote}" != "${UI_SERVER_REPO}" ]; then
        echo "ERROR: ${UI_SERVER_DIR} tracks ${existing_remote}, not ${UI_SERVER_REPO}." >&2
        echo "       Remove the directory or set TQEM_UI_SERVER_DIR to a fresh path." >&2
        exit 1
    fi
    if [ -n "$(git -C "${UI_SERVER_DIR}" status --porcelain)" ]; then
        echo "ERROR: ${UI_SERVER_DIR} has local changes; refusing to switch branches." >&2
        echo "       Commit, stash, or discard the changes before re-running." >&2
        exit 1
    fi
fi
git -C "${UI_SERVER_DIR}" fetch --tags --prune origin
git -C "${UI_SERVER_DIR}" checkout --detach "origin/${UI_SERVER_VERSION}"

# Generate .env for UI-Server (BRANDING/TARGET keys are read by the UI-Server's
# vite dev config; the VITE_-prefixed variants are exposed to client code).
cat > "${UI_FRONTEND_DIR}/.env" << EOF
BRANDING=${BRANDING}
TARGET=${TARGET_URL}
VITE_BRANDING=${BRANDING}
VITE_TARGET=${TARGET_URL}
EOF

# Symlink App build output into UI-Server apps/. The app's vite dev build
# writes to container/frontend/apps/<APP_ID>/ (see app's vite-dev-utils.js),
# so the symlink target must match that path.
APP_BUILD_OUTPUT_DIR="${APP_FRONTEND_DIR}/container/frontend/apps/${APP_ID}"
mkdir -p "${APP_BUILD_OUTPUT_DIR}"
mkdir -p "${APPS_DIR}"
rm -f "${APPS_DIR}/${APP_ID}"
ln -s "${APP_BUILD_OUTPUT_DIR}" "${APPS_DIR}/${APP_ID}"

# Register App in UI-Server
printf '["%s/index.js"]\n' "${APP_ID}" > "${APPS_DIR}/apps.json"
printf '["%s/i18n/lang.js"]\n' "${APP_ID}" > "${APPS_DIR}/langs.json"

# Install dependencies
echo "Installing UI-Server dependencies..."
cd "${UI_FRONTEND_DIR}"
COREPACK_ENABLE_DOWNLOAD_PROMPT=0 yarn install

echo "Installing App frontend dependencies..."
cd "${APP_FRONTEND_DIR}"
COREPACK_ENABLE_DOWNLOAD_PROMPT=0 yarn install

# Start App frontend build in watch mode (background). Branding is passed as
# environment variable so the app repository does not need to keep a .env file.
# setsid puts the watcher into its own process group so we can take down the
# whole tree (vite, esbuild workers, ...) on exit, not just the top-level yarn.
echo "Starting App frontend build in watch mode..."
# shellcheck disable=SC2016  # $1 is intentionally expanded by the inner shell
setsid bash -c 'BRANDING="$1" VITE_BRANDING="$1" exec yarn dev' _ "${BRANDING}" &
APP_DEV_PID=$!
trap 'kill -TERM -"${APP_DEV_PID}" 2>/dev/null || true' EXIT INT TERM

# Start UI-Server dev server (foreground). The bind address is controlled by
# TQEM_FRONTEND_DEV_HOST (default 0.0.0.0); set it to 127.0.0.1 to restrict
# the server to the local machine.
echo "Starting UI-Server dev server on ${DEV_HOST}..."
cd "${UI_FRONTEND_DIR}"
yarn dev --host "${DEV_HOST}"
