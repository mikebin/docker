#!/bin/bash

docker-machine create --driver virtualbox --virtualbox-memory 10000 docker
eval $(docker-machine env docker)
docker-machine start docker
