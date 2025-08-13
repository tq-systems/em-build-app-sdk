include environment.mk

MAKE_DOCS := cd ${TQEM_REL_DOCS_DIR} && $(MAKE)

test-complete:
	ssh ${TQEM_EXTERNAL_BUILD_HOSTNAME} \
		"rm -rf ${TQEM_REL_WORKING_DIR}; mkdir ${TQEM_REL_WORKING_DIR}; docker system prune -a -f"
	rsync -zav --exclude '.git' --exclude 'artifacts' --exclude 'docs' \
		./* ${TQEM_EXTERNAL_HOME_DIR}/${TQEM_REL_WORKING_DIR}
	ssh ${TQEM_EXTERNAL_BUILD_HOSTNAME} "hostname; whoami; ls -la ${TQEM_REL_WORKING_DIR}"

docs:
	$(MAKE_DOCS) html
	$(MAKE_DOCS) latexpdf
	mkdir -p ${TQEM_REL_DOCS_ARTIFACTS_DIR}
	cp -r ${TQEM_REL_DOCS_DIR}/build/html ${TQEM_REL_DOCS_ARTIFACTS_DIR}/
	cp ${TQEM_REL_DOCS_DIR}/build/latex/*.pdf ${TQEM_REL_DOCS_ARTIFACTS_DIR}/

clean:
	rm -rf ${TQEM_REL_DOCS_DIR}/build
	rm -rf ${TQEM_REL_ARTIFACTS_DIR}

.PHONY: test-complete docs clean
