
PROJECT_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))

# run `make version-sync` on changes
VERSION := 1.0.0
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

include $(PROJECT_ROOT)/../.project/common.mk
