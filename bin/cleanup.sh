#!/bin/bash 

docker images -qf dangling=true | xargs docker rmi
docker volume ls -q -f dangling=true | xargs docker volume rm
