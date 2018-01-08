
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
version-sync: $(PROJECT_ROOT)/Dockerfile $(PROJECT_ROOT)/hooks/build $(PROJECT_ROOT)/hooks/post_push
	@sed -i \
		-e 's|ENV UNIFI_VERSION=.*|ENV UNIFI_VERSION=$(VERSION)|g' \
		$(PROJECT_ROOT)/Dockerfile
	@sed -i \
		-e 's|VERSION=.*|VERSION=$(VERSION)-$(REVISION)|g' \
		$(PROJECT_ROOT)/hooks/build
	@sed -i \
		-e 's|VERSION=.*|VERSION=$(VERSION)|g' \
		$(PROJECT_ROOT)/hooks/post_push

include $(PROJECT_ROOT)/../.project/common.mk