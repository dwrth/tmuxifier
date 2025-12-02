FETCHED_FILES :=

# $(1) = local file path, $(2) = remote URL, $(3) = optional post-curl command
define FETCH_FILE
FETCHED_FILES += $(1)

$(1):
	echo "fetching $(1)..." && \
	mkdir -p $(dir $(1)) && \
	curl -s -L -o $(1) $(2)$(if $(3), && $(3),)

remove_$(1):
	test -f "$(1)" && rm "$(1)" && echo "removed $(1)" || true

update_$(1): remove_$(1) $(1)
endef

$(eval $(call FETCH_FILE,tests/bashunit,\
	https://github.com/TypedDevs/bashunit/releases/download/0.26.0/bashunit,\
	chmod +x tests/bashunit))

$(eval $(call FETCH_FILE,test-legacy/test-runner.sh,\
	https://github.com/jimeh/test-runner.sh/raw/v0.2.0/test-runner.sh,\
	chmod +x test-legacy/test-runner.sh))
$(eval $(call FETCH_FILE,test-legacy/assert.sh,\
	https://raw.github.com/lehmannro/assert.sh/v1.0.2/assert.sh))
$(eval $(call FETCH_FILE,test-legacy/stub.sh,\
	https://raw.github.com/jimeh/stub.sh/v1.0.1/stub.sh))

test: bootstrap
	./tests/bashunit $(FILE)

test-legacy: bootstrap
	./test-legacy/test-runner.sh $(FILE)

bootstrap: $(FETCHED_FILES)
clean: $(addprefix remove_,$(FETCHED_FILES))
update: $(addprefix update_,$(FETCHED_FILES))

.SILENT:
.PHONY: test bootstrap clean update \
	$(addprefix remove_,$(FETCHED_FILES)) \
	$(addprefix update_,$(FETCHED_FILES))
