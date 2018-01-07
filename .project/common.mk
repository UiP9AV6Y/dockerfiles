# shared GNU Make library

BUILD_DATE = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_BRANCH = $(shell git symbolic-ref --short HEAD)
VCS_URL = $(shell git config --get remote.origin.url)
VCS_REF = $(shell git rev-parse --short HEAD)

ifndef PROJECT_ROOT
$(error PROJECT_ROOT has not been defined)
endif

DOCKER_IMAGE ?= $(notdir $(patsubst %/,%,$(realpath $(PROJECT_ROOT))))
DOCKER_USER ?= library
DOCKER ?= docker
DOCKER_REPO = $(DOCKER_USER)/$(DOCKER_IMAGE)

DOCKER_REPO_IMAGES = $(shell $(DOCKER) image ls \
	--filter "reference=$(DOCKER_REPO)" \
	--format '{{.Repository}}:{{.Tag}}' \
)

.PHONY: help
help:
	$(info No target has been specified)

.PHONY: docker-cloud-build
docker-cloud-build: $(PROJECT_ROOT)/hooks/build
	cd $(PROJECT_ROOT) && \
	COMMIT_MSG="" \
	SOURCE_BRANCH=$(VCS_BRANCH) \
	SOURCE_COMMIT=$(VCS_REF) \
	DOCKER_REPO=$(DOCKER_REPO) \
	CACHE_TAG=build-$(VCS_REF) \
	IMAGE_NAME=$(DOCKER_REPO):build-$(VCS_BRANCH) \
	$(PROJECT_ROOT)/hooks/build

.PHONY: docker-cloud-release
docker-cloud-release: $(PROJECT_ROOT)/hooks/post_push
	cd $(PROJECT_ROOT) && \
	COMMIT_MSG="" \
	SOURCE_BRANCH=$(VCS_BRANCH) \
	SOURCE_COMMIT=$(VCS_REF) \
	DOCKER_REPO=$(DOCKER_REPO) \
	CACHE_TAG=build-$(VCS_REF) \
	IMAGE_NAME=$(DOCKER_REPO):build-$(VCS_BRANCH) \
	$(PROJECT_ROOT)/hooks/post_push

# the post_push hook usually creates additional tags.
# since we do not know about them, we simply prune all
# tags for the current image
# (we could accept the tags as variables, but this just
# makes it verbose)
.PHONY: docker-cloud-clean
docker-cloud-clean: docker-prune

.PHONY: docker-build
docker-build:
	$(DOCKER) image build $(DOCKER_BUILD_ARGV) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-t $(DOCKER_REPO):build-$(VCS_BRANCH) \
		$(PROJECT_ROOT)

.PHONY: docker-clean
docker-clean:
	$(docker) image rm \
		$(DOCKER_REPO):build-$(VCS_BRANCH)

.PHONY: docker-prune
docker-prune:
ifneq ($(DOCKER_REPO_IMAGES),)
	$(DOCKER) image rm \
		$(DOCKER_REPO_IMAGES)
endif

.PHONY: %-docker-tag
%-docker-tag:
	$(DOCKER) image tag \
		$(DOCKER_REPO):$(@:-docker-tag=)

.PHONY: %-docker-push
%-docker-push:
	$(DOCKER) image push \
		$(DOCKER_REPO):$(@:-docker-push=)

.PHONY: %-docker-clean
%-docker-clean:
	$(DOCKER) image rm \
		$(DOCKER_REPO):$(@:-docker-clean=)