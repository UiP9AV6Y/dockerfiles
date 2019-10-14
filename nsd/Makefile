
PROJECT_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))

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
