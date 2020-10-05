VERSION?=1.0.0
IMAGE_NAME=jodonnellhashi/runner:$(VERSION)
DOCKER_DIR=./build

.PHONY: all build
all: build

build:
	docker build --no-cache -t $(IMAGE_NAME) .
