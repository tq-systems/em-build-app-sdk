include environment.mk

RUN_DOCKER := ./scripts/docker-run.sh
RUN_YOCTO := ${RUN_DOCKER} ${BASE_REGISTRY}/yocto:${BASE_DOCKER_TAG}
RUN_AARCH64 := ${RUN_DOCKER} ${PUBLIC_TOOLCHAIN_REGISTRY}/aarch64:${PUBLIC_TOOLCHAIN_DOCKER_TAG}

MAKE_DOCS := cd ${TQEM_DOCS_DIR} && $(MAKE)

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
	$(MAKE) demo-bundle

# Build
prepare:
	./scripts/prepare_projects.py

base:
	$(MAKE) -C ${TQEM_BUILD_BASE_DIR} all

core: core-build
	$(MAKE) core-deploy

core-build:
	$(RUN_YOCTO) $(MAKE) -C ${TQEM_BUILD_YOCTO_DIR} all

core-deploy:
	$(RUN_YOCTO) $(MAKE) -C ${TQEM_BUILD_YOCTO_DIR} deploy

toolchain:
	$(MAKE) -C ${TQEM_BUILD_TOOLCHAIN_DIR} all

# Characteristics of app/bundle builds must be considered:
# A separate 'make prepare' is required to create VERSION.txt first and read it during include
# of version.mk. Parallel build issues are prevented by setting '-j1'.
go-demo-app:
	$(RUN_AARCH64) $(MAKE) -C ${TQEM_BUILD_APPS_DIR}/go-demo prepare
	$(RUN_AARCH64) $(MAKE) -j1 -C ${TQEM_BUILD_APPS_DIR}/go-demo all deploy-snapshot

demo-bundle:
	$(RUN_AARCH64) $(MAKE) -C ${TQEM_BUILD_BUNDLES_DIR}/demo prepare
	$(RUN_AARCH64) $(MAKE) -j1 -C ${TQEM_BUILD_BUNDLES_DIR}/demo all deploy-snapshot

docs:
	$(MAKE_DOCS) html
	$(MAKE_DOCS) latexpdf
	mkdir -p ${TQEM_DOCS_ARTIFACTS_DIR}
	cp -r ${TQEM_BUILD_DOCS_DIR}/html ${TQEM_DOCS_ARTIFACTS_DIR}/
	cp ${TQEM_BUILD_DOCS_DIR}/latex/*.pdf ${TQEM_DOCS_ARTIFACTS_DIR}/

# Test
test-all: clean clean-docker
	$(MAKE) all

run-aarch64-bash:
	$(RUN_AARCH64) bash

# Clean
clean-demo:
	$(RUN_AARCH64) $(MAKE) -C ${TQEM_BUILD_APPS_DIR}/go-demo clean
	$(RUN_AARCH64) $(MAKE) -C ${TQEM_BUILD_BUNDLES_DIR}/demo clean

clean-docker:
	docker system prune --force

clean:
	rm -rf ${TQEM_BUILD_DIR} ${TQEM_BUILD_DOCS_DIR}

.PHONY: all prepare \
	base core core-build core-deploy toolchain go-demo-app demo-bundle \
	docs \
	test-all test-from-scratch run-aarch64-bash \
	clean-demo clean-docker clean
