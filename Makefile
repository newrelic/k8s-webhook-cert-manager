DOCKER_IMAGE_NAME=newrelic/k8s-webhook-cert-manager
DOCKER_IMAGE_TAG=latest

.PHONY: all
all: build

.PHONY: build
build:
	docker build -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) .
