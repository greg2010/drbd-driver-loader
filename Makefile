PROJECT ?= drbd9
DF = Dockerfile.bookworm
NOCACHE ?= false
PLATFORMS ?= linux/amd64

ifdef IMAGE_NAME
IMAGE_NAME := $(IMAGE_NAME)
else
IMAGE_NAME := drbd-driver-loader
endif

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:

	for version_env in ./VERSION*.env ; do \
		. $$version_env ; \
		for f in $(DF); do \
			pd=$(PROJECT)-$$(echo $$f | sed 's/^Dockerfile\.//'); \
			docker buildx build $(_EXTRA_ARGS) --build-arg DRBD_VERSION=$$DRBD_VERSION --no-cache=$(NOCACHE) --platform=$(PLATFORMS) -f $$f \
				--tag $(IMAGE_NAME)/$$pd:v$$DRBD_VERSION . ; \
		done; \
	done

.PHONY: upload
upload:
	make update _EXTRA_ARGS=--push