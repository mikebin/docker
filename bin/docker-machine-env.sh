#!/bin/bash

docker-machine status docker >/dev/null 2>/dev/null || docker-machine create --driver virtualbox --virtualbox-memory 10000 docker

eval $(docker-machine env docker)
