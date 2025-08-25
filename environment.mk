# Build directories
TQEM_REL_DOCS_DIR ?= docs
TQEM_REL_WORKING_DIR ?= appsdk

# Artifacts directories
TQEM_REL_ARTIFACTS_DIR ?= artifacts
TQEM_REL_DOCS_ARTIFACTS_DIR ?= ${TQEM_REL_ARTIFACTS_DIR}/docs

# Definition for external build server with an SSH connection
TQEM_EXTERNAL_BUILD_HOSTNAME ?= external-build
TQEM_EXTERNAL_HOME_DIR ?= ${TQEM_EXTERNAL_BUILD_HOSTNAME}:/home/tqemci
