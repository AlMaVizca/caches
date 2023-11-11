ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
include $(ROOT_DIR)/.mk-lib/common.mk
include .env
export

.EXPORT_ALL_VARIABLES:
.PHONY: help build services stop

build: # build image i=mysql:5.7
	@docker pull $(i)
	@cat Dockerfile | perl -pe "s/IMAGE/$(i)/g" > .Dockerfile.$(i)
	@docker image tag $(i) $(i)-original
	@docker build -t $(i) -f .Dockerfile.$i .

rebuild: # build image using customizations i=mysql:5.7
	@docker build -t $(i) -f .Dockerfile.$i .

clean:
	@docker pull $(i)

start: # start all cache services c=
	@docker-compose up -d ${c}

stop: # stop all services
	@docker-compose stop

start-service: # start c=<cache service>
	@docker-compose up ${c}

stop-service: # stop c=<cache service>
	@docker-compose stop ${c}

down: # clean all services
	@docker-compose down

logs-npm:
	@docker logs -f -n50 cache-npm-1

logs-apt:
	@docker logs -f -n50 cache-apt-1

install-sockets: # c=<cache_service> to enable socket activation
	./socket-activation/setup.sh $(c)
