# Optional local environment overrides
-include local/environment.mk
# Default environment settings
include environment.mk

RUN_DOCKER := ./scripts/docker-run.sh
RUN_YOCTO := ${RUN_DOCKER} ${BASE_REGISTRY}/yocto:${BASE_DOCKER_TAG}
RUN_AARCH64 := ${RUN_DOCKER} ${PUBLIC_TOOLCHAIN_REGISTRY}/aarch64:${PUBLIC_TOOLCHAIN_DOCKER_TAG}

MAKE_DOCS := cd ${TQEM_DOCS_DIR} && $(MAKE)
MAKE_AARCH64 := $(RUN_AARCH64) $(MAKE)

# Set 'CLEAN_CORE=true' to delete yocto's build cache for incremental builds,
# particularly as the core build takes a very long time.
CLEAN_CORE ?= false
# Set 'CLEAN_BUILD=true' to delete all build directories including all build caches.
CLEAN_BUILD ?= false

# Use current uid/gid for the docker builds to prevent permission issues
export DOCKER_UID ?= $(shell id -u)
export DOCKER_GID ?= $(shell id -g)

# Only the main target fulfill all dependencies. All other targets intentionally
# do not maintain dependencies so they can be executed independently.

# Main target
all: prepare
	$(MAKE) base
	$(MAKE) core
	$(MAKE) toolchain
	$(MAKE) go-demo-app
	$(MAKE) open-ui-container-app
	$(MAKE) demo-bundle

# Rebuild all targets, the core build is kept unless CLEAN_CORE=true.
# A clean command may fail if a docker image does not exist yet.
rebuild:
	$(MAKE) clean || true
	$(MAKE) all

# Build
prepare:
	$(PREPARE_SCRIPT)

base:
	$(MAKE) -C ${TQEM_BUILD_BASE_DIR} all \
		BUILD_TAG=${BASE_DOCKER_TAG}

core: core-build
	$(MAKE) core-deploy

core-build:
	$(RUN_YOCTO) $(MAKE) -C ${TQEM_BUILD_YOCTO_DIR} all

core-deploy:
	$(RUN_YOCTO) $(MAKE) -C ${TQEM_BUILD_YOCTO_DIR} snapshot-deploy

toolchain:
	$(MAKE) -C ${TQEM_BUILD_TOOLCHAIN_DIR} all \
		BUILD_TAG=${PUBLIC_TOOLCHAIN_DOCKER_TAG} \
		TQEM_CORE_TYPE=snapshots

# Currently, certain make targets still need to be executed sequentially to avoid issues
# during builds that use multiple CPU threads.
go-demo-app:
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/go-demo prepare
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/go-demo all
	$(eval SUBDIR := $(shell ${PREPARE_SCRIPT} --ref apps/go-demo))
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/go-demo deploy-snapshot \
		TQEM_DEPLOYMENT_SUBDIR=${SUBDIR}

open-ui-container-app:
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/open-ui-container prepare
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/open-ui-container all
	$(eval SUBDIR := $(shell ${PREPARE_SCRIPT} --ref apps/open-ui-container))
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/open-ui-container deploy-snapshot \
		TQEM_DEPLOYMENT_SUBDIR=${SUBDIR}

demo-bundle:
	$(MAKE_AARCH64) -C ${TQEM_BUILD_BUNDLES_DIR}/demo prepare
	$(MAKE_AARCH64) -C ${TQEM_BUILD_BUNDLES_DIR}/demo all
	$(eval SUBDIR := $(shell ${PREPARE_SCRIPT} --ref bundles/demo))
	$(MAKE_AARCH64) -C ${TQEM_BUILD_BUNDLES_DIR}/demo deploy-snapshot \
		TQEM_DEPLOYMENT_SUBDIR=${SUBDIR}

frontend-dev:
	./scripts/frontend-dev.sh

frontend-dev-check:
	./scripts/frontend-dev.sh --check

docs:
	$(MAKE_DOCS) html
	$(MAKE_DOCS) latexpdf
	mkdir -p ${TQEM_DOCS_ARTIFACTS_DIR}
	cp -r ${TQEM_BUILD_DOCS_DIR}/html ${TQEM_DOCS_ARTIFACTS_DIR}/
	cp ${TQEM_BUILD_DOCS_DIR}/latex/*.pdf ${TQEM_DOCS_ARTIFACTS_DIR}/

# Test
run-aarch64-bash:
	$(RUN_AARCH64) bash

# Clean
clean-docker:
	docker system prune --force

clean-core:
ifeq ($(CLEAN_CORE),true)
	rm -rf ${TQEM_BUILD_YOCTO_DIR}/em-build/build
endif

# Remove old toolchain build artifacts (core image, SDK toolchain)
clean-toolchain:
	$(MAKE) -C ${TQEM_BUILD_TOOLCHAIN_DIR} clean

clean-demo:
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/go-demo           clean
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/open-ui-container clean
	$(MAKE_AARCH64) -C ${TQEM_BUILD_BUNDLES_DIR}/demo           clean

clean-docs:
	rm -rf ${TQEM_BUILD_DOCS_DIR}

clean: clean-docker clean-docs
ifeq ($(CLEAN_BUILD),true)
	rm -rf ${TQEM_BUILD_DIR}
else
	$(MAKE) clean-core clean-toolchain clean-demo
endif

.PHONY: all rebuild prepare \
	base core core-build core-deploy toolchain \
	go-demo-app open-ui-container-app demo-bundle \
	frontend-dev frontend-dev-check \
	docs run-aarch64-bash \
	clean-docker clean-core clean-toolchain clean-demo clean-docs clean
