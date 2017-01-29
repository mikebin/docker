#!/bin/bash

kafka-topics --create --topic c3-test --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

while true;
do
  docker run \
    --net=kafka_default \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-3.1.1.jar \
    confluentinc/cp-kafka-connect:3.1.1 \
    bash -c 'seq 10000 | kafka-console-producer --request-required-acks 1 --broker-list kafka0:9090 --topic c3-test --producer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor --producer-property acks=1 && echo "Produced 10000 messages."'
    sleep 10;
done

OFFSET=0
while true;
do
  docker run \
    --net=kafka_default \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-3.1.1.jar \
    confluentinc/cp-kafka-connect:3.1.1 \
    bash -c 'kafka-console-consumer --consumer-property group.id=qs-consumer --consumer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor --new-consumer --bootstrap-server kafka0:9090 --topic c3-test --offset '$OFFSET' --partition 0 --max-messages=1000'
  sleep 1;
  let OFFSET=OFFSET+1000
done
