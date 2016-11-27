#!/bin/bash

alias kafka-topics='docker exec -i kafka0 kafka-topics'
alias kafka-console-producer='docker exec -i kafka0 kafka-console-producer'
alias kafka-console-consumer='docker exec -i kafka0 kafka-console-consumer'
alias kafka-producer-perf-test='docker exec -i kafka0 kafka-producer-perf-test'
alias kafka-consumer-perf-test='docker exec -i kafka0 kafka-consumer-perf-test'
alias confluent-rebalancer='docker exec -i kafka0 confluent-rebalancer'

docker-compose down

docker-compose up -d zookeeper kafka0 kafka1 kafka2

kafka-topics --create --topic adb-test --partitions 20 --replication-factor 3 --if-not-exists --zookeeper zookeeper:2181

kafka-topics --topic adb-test --describe --zookeeper zookeeper:2181

kafka-producer-perf-test --topic adb-test --num-records 200000 --record-size 1000 --throughput 100000 --producer-props bootstrap.servers=kafka0:9090

confluent-rebalancer execute --zookeeper zookeeper:2181 --metrics-bootstrap-server kafka2:9092 --throttle 100000000 --force --verbose

confluent-rebalancer status --zookeeper zookeeper:2181

confluent-rebalancer finish --zookeeper zookeeper:2181

kafka-topics --topic adb-test --describe --zookeeper zookeeper:2181

confluent-rebalancer execute --zookeeper zookeeper:2181 --metrics-bootstrap-server kafka2:9092 --throttle 100000000 --force --verbose

confluent-rebalancer status --zookeeper zookeeper:2181

confluent-rebalancer finish --zookeeper zookeeper:2181

kafka-topics --topic adb-test --describe --zookeeper zookeeper:2181

docker-compose up -d kafka3 kafka4 kafka5
