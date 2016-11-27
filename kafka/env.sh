#!/bin/bash

alias kafka-topics='docker exec -i kafka0 kafka-topics'
alias kafka-console-producer='docker exec -i kafka0 kafka-console-producer'
alias kafka-console-consumer='docker exec -i kafka0 kafka-console-consumer'
alias kafka-producer-perf-test='docker exec -i kafka0 kafka-producer-perf-test'
alias kafka-consumer-perf-test='docker exec -i kafka0 kafka-consumer-perf-test'
alias confluent-rebalancer='docker exec -i kafka0 confluent-rebalancer'

