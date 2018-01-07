
PROJECT_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))
IMAGES := unifi-controller

.PHONY: default
default: all

.PHONY: all
all: $(IMAGES)

.PHONY: $(IMAGES)
$(IMAGES):
	cd $@ && $(MAKE)

.PHONY: build
build: $(IMAGES:=/build)

.PHONY: publish
publish: $(IMAGES:/publish)

.PHONY: clean
clean: $(IMAGES:=/clean)

.PHONY: %/build
%/build:
	cd $(@D) && $(MAKE) build

.PHONY: %/publish
%/publish:
	cd $(@D) && $(MAKE) publish

.PHONY: %/clean
%/clean:
	cd $(@D) && $(MAKE) clean