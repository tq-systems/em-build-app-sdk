# Export environment variables
export TQEM_EM_AARCH64_MACHINE ?= em4xx
export TQEM_MACHINE ?= em4xx

export TQEM_EMOS_DIRNAME ?= emos

export TQEM_SNAPSHOTS_DIRNAME  ?= snapshots
export TQEM_RCS_DIRNAME        ?= release-candidates
export TQEM_RELEASES_DIRNAME   ?= releases
export TQEM_BUILD_TYPE_DIRNAME ?= ${TQEM_SNAPSHOTS_DIRNAME}

export TQEM_APPSDK_PATH       = $(CURDIR)
export TQEM_BUILD_CACHE_PATH ?= ${TQEM_APPSDK_PATH}/${TQEM_BUILD_DIR}/cache
export TQEM_APPS_CACHE_PATH  ?= ${TQEM_BUILD_CACHE_PATH}/apps

export TQEM_BASE_DEPLOY_PATH ?= $(HOME)/workspace/tqem/deploy

# Build directories
TQEM_DOCS_DIR ?= docs
TQEM_BUILD_DOCS_DIR ?= ${TQEM_DOCS_DIR}/build

TQEM_WORKING_DIR ?= appsdk

TQEM_BUILD_DIR           ?= build
TQEM_BUILD_BASE_DIR      ?= ${TQEM_BUILD_DIR}/base
TQEM_BUILD_YOCTO_DIR     ?= ${TQEM_BUILD_DIR}/yocto
TQEM_BUILD_TOOLCHAIN_DIR ?= ${TQEM_BUILD_DIR}/toolchain
TQEM_BUILD_APPS_DIR      ?= ${TQEM_BUILD_DIR}/apps
TQEM_BUILD_BUNDLES_DIR   ?= ${TQEM_BUILD_DIR}/bundles


# Artifacts directories
TQEM_ARTIFACTS_DIR ?= artifacts
TQEM_DOCS_ARTIFACTS_DIR ?= ${TQEM_ARTIFACTS_DIR}/docs

# Docker registries
LOCAL_BASE      = local/em/base
LOCAL_TOOLCHAIN = local/em/toolchain

BASE_REGISTRY             ?= ${LOCAL_BASE}
PUBLIC_TOOLCHAIN_REGISTRY ?= ${LOCAL_TOOLCHAIN}

# Definition for external build server with an SSH connection
TQEM_CI_HOSTNAME    ?= external-build
TQEM_CI_HOME_PATH   ?= /home/tqemci
TQEM_CI_DESTINATION ?= ${TQEM_CI_HOSTNAME}:${TQEM_CI_HOME_PATH}

# Docker tags
BASE_DOCKER_TAG ?= latest
PUBLIC_TOOLCHAIN_DOCKER_TAG ?= latest
