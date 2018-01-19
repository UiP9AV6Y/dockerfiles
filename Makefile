
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

%:
	@cp -r \
		$(PROJECT_ROOT)/.project/scaffold \
		$(PROJECT_ROOT)/$@
	@sed -i \
		-e "s|@PROJECT@|$@|g" \
		$(PROJECT_ROOT)/$@/Dockerfile
	@$(info $(PROJECT_ROOT)/$@ created)