include environment.mk

MAKE_DOCS := cd ${TQEM_REL_DOCS_DIR} && $(MAKE)

docs:
	$(MAKE_DOCS) html
	$(MAKE_DOCS) latexpdf
	mkdir -p ${TQEM_REL_DOCS_ARTIFACTS_DIR}
	cp -r ${TQEM_REL_DOCS_DIR}/build/html ${TQEM_REL_DOCS_ARTIFACTS_DIR}/
	cp ${TQEM_REL_DOCS_DIR}/build/latex/*.pdf ${TQEM_REL_DOCS_ARTIFACTS_DIR}/

clean:
	rm -rf ${TQEM_REL_DOCS_DIR}/build
	rm -rf ${TQEM_REL_ARTIFACTS_DIR}

.PHONY: docs clean
