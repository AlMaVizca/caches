ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
include $(ROOT_DIR)/.mk-lib/common.mk
include .env
export

.EXPORT_ALL_VARIABLES:
.PHONY: help build rebiuld services start stop down logs-npm logs-apt install-sockets

build: ## Build image i=python
	@docker pull $(i)
	@cat Dockerfile | perl -pe "s/IMAGE/$(i)/g" > .Dockerfile.$(i)
	@docker image tag $(i) $(i)-original
	@docker build -t $(i) -f .Dockerfile.$i .

rebuild: ## Build image using customizations i=python
	@docker build -t $(i) -f .Dockerfile.$i .

clean:  ## Get the original image
	@docker pull $(i)

start: network ## Start all cache services c=
	@docker-compose up -d ${c}

stop: ## Stop all services
	@docker-compose stop

start-service: # start c=<cache service> to be used with socket activation
	@docker-compose up ${c}

stop-service: # stop c=<cache service> to be used with socket activation
	@docker-compose stop ${c}

down: ## clean all services
	@docker-compose down

logs-npm: ## Watch npm cache logs
	@docker logs -f -n50 cache_npm

logs-apt: ## Watch apt cache logs
	@docker logs -f -n50 cache_apt

install-sockets: ## c=<cache_service> to enable socket activation
	./socket-activation/setup.sh $(c)

network: ## Create proxy network
	-@docker network create lb
