
PROJECT_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))

# run `make version-sync` on changes
VERSION := 5.6.29
REVISION := 0


.PHONY: default
default: all

.PHONY: all
all: build publish

.PHONY: build
build: docker-cloud-build

.PHONY: publish
publish: docker-cloud-release

.PHONY: clean
clean: docker-cloud-clean

.PHONY: version-sync
version-sync: $(PROJECT_ROOT)/hooks/build $(PROJECT_ROOT)/hooks/post_push $(PROJECT_ROOT)/Dockerfile
	@sed -i \
		-re 's|^VERSION=.+|VERSION=$(VERSION)-$(REVISION)|' \
		$(PROJECT_ROOT)/hooks/build
	@sed -i \
		-re 's|^VERSION=.+|VERSION=$(VERSION)|' \
		$(PROJECT_ROOT)/hooks/post_push
	@sed -i \
		-re 's|^(ENV UNIFI_VERSION)=.+|\1=$(VERSION)|' \
		$(PROJECT_ROOT)/Dockerfile

include $(PROJECT_ROOT)/../.project/common.mk