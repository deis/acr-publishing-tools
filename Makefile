GIT_VERSION = $(shell git describe --always --abbrev=7 --dirty)

BASE_IMAGE_NAME        = acr-publishing-tools

RC_IMAGE_NAME          = $(RC_DOCKER_REPO)$(BASE_IMAGE_NAME):$(GIT_VERSION)
RC_MUTABLE_IMAGE_NAME  = $(RC_DOCKER_REPO)$(BASE_IMAGE_NAME):canary

REL_IMAGE_NAME         = $(REL_DOCKER_REPO)$(BASE_IMAGE_NAME):$(REL_VERSION)
REL_MUTABLE_IMAGE_NAME = $(REL_DOCKER_REPO)$(BASE_IMAGE_NAME):latest

# Checks for the existence of a docker client and prints a nice error message
# if it isn't present
.PHONY: check-docker
check-docker:
	@if [ -z $$(which docker) ]; then \
		echo "Missing \`docker\` client which is required for development"; \
		exit 2; \
	fi

# Build the Docker image
.PHONY: build
build: check-docker
	docker build -t $(RC_IMAGE_NAME) .
	docker tag $(RC_IMAGE_NAME) $(RC_MUTABLE_IMAGE_NAME)

# Push the release candidate Docker images
.PHONY: push-rc
push-rc: check-docker build
	docker push $(RC_IMAGE_NAME)
	docker push $(RC_MUTABLE_IMAGE_NAME)

# Push the release / semver Docker images
.PHONY: push-release
push-release:
ifndef REL_VERSION
	$(error REL_VERSION is undefined)
endif
	docker pull $(RC_IMAGE_NAME)
	docker tag $(RC_IMAGE_NAME) $(REL_IMAGE_NAME)
	docker tag $(RC_IMAGE_NAME) $(REL_MUTABLE_IMAGE_NAME)
	docker push $(REL_IMAGE_NAME)
	docker push $(REL_MUTABLE_IMAGE_NAME)
