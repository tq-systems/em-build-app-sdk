include environment.mk

RUN_DOCKER := ./scripts/docker-run.sh
RUN_YOCTO := ${RUN_DOCKER} ${BASE_REGISTRY}/yocto:${BASE_DOCKER_TAG}
RUN_AARCH64 := ${RUN_DOCKER} ${PUBLIC_TOOLCHAIN_REGISTRY}/aarch64:${PUBLIC_TOOLCHAIN_DOCKER_TAG}

MAKE_DOCS := cd ${TQEM_DOCS_DIR} && $(MAKE)
MAKE_AARCH64 := $(RUN_AARCH64) $(MAKE_ENV) $(MAKE)

CLEAN_BUILD ?= true

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

# Rebuild all targets, the core build is kept unless CLEAN_BUILD=true.
rebuild: clean
	$(MAKE) all

# Build
prepare:
	$(PREPARE_SCRIPT)

base:
	$(MAKE) -C ${TQEM_BUILD_BASE_DIR} all

core: core-build
	$(MAKE) core-deploy

core-build:
	$(eval URL := $(shell $(PREPARE_SCRIPT) --url yocto/em-build))
	$(eval REF := $(shell $(PREPARE_SCRIPT) --ref yocto/em-build))
	$(RUN_YOCTO) $(MAKE) -C ${TQEM_BUILD_YOCTO_DIR} all \
		TQEM_EM_BUILD_GIT_REPO=${URL} \
		TQEM_EM_BUILD_REF=${REF}

core-deploy:
	$(RUN_YOCTO) $(MAKE) -C ${TQEM_BUILD_YOCTO_DIR} snapshot-deploy

toolchain:
	$(MAKE) -C ${TQEM_BUILD_TOOLCHAIN_DIR} all

# Currently, certain make targets still need to be executed sequentially to avoid issues
# during builds that use multiple CPU threads.
go-demo-app:
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/go-demo prepare
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/go-demo all
	$(eval MAKE_ENV := TQEM_DEPLOYMENT_SUBDIR=$(shell $(PREPARE_SCRIPT) --ref apps/go-demo))
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/go-demo deploy-snapshot

open-ui-container-app:
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/open-ui-container prepare
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/open-ui-container all
	$(eval MAKE_ENV := TQEM_DEPLOYMENT_SUBDIR=$(shell $(PREPARE_SCRIPT) --ref apps/open-ui-container))
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/open-ui-container deploy-snapshot

demo-bundle:
	$(MAKE_AARCH64) -C ${TQEM_BUILD_BUNDLES_DIR}/demo prepare
	$(MAKE_AARCH64) -C ${TQEM_BUILD_BUNDLES_DIR}/demo all
	$(eval MAKE_ENV := TQEM_DEPLOYMENT_SUBDIR=$(shell $(PREPARE_SCRIPT) --ref bundles/demo))
	$(MAKE_AARCH64) -C ${TQEM_BUILD_BUNDLES_DIR}/demo deploy-snapshot

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
test-all: clean
	$(MAKE) all

run-aarch64-bash:
	$(RUN_AARCH64) bash

# Clean
clean-demo:
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/go-demo           clean
	$(MAKE_AARCH64) -C ${TQEM_BUILD_APPS_DIR}/open-ui-container clean
	$(MAKE_AARCH64) -C ${TQEM_BUILD_BUNDLES_DIR}/demo           clean

clean-docker:
	docker system prune --force

clean-docs:
	rm -rf ${TQEM_BUILD_DOCS_DIR}

# Set 'CLEAN_BUILD=false' to retain the build cache for incremental builds,
# particularly as the core build takes a very long time.
clean-build:
ifeq ($(CLEAN_BUILD),true)
	rm -rf ${TQEM_BUILD_DIR}
endif

# Remove old toolchain build artifacts (core image, SDK toolchain)
clean-toolchain:
	$(MAKE) -C ${TQEM_BUILD_TOOLCHAIN_DIR} clean

clean: clean-demo clean-docker clean-docs clean-build clean-toolchain

.PHONY: all prepare \
	base core core-build core-deploy toolchain \
	go-demo-app open-ui-container-app demo-bundle \
	frontend-dev frontend-dev-check \
	docs \
	test-all run-aarch64-bash \
	clean-demo clean-docker clean-docs clean-build clean-toolchain clean
