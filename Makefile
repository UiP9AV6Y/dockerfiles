
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
		-e "s|@PROJECT_CASE@|$(shell echo $@ | tr [:lower:] [:upper:] | sed -e 's|-|_|g')|g" \
		$(PROJECT_ROOT)/$@/Dockerfile \
		$(PROJECT_ROOT)/$@/hooks/*
	@$(info $(PROJECT_ROOT)/$@ created)
