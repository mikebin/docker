#!/bin/bash

kafka-topics --create --topic docker-connect-offsets --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

kafka-topics --create --topic docker-connect-configs --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

kafka-topics --create --topic docker-connect-status --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

kafka-topics --create --topic quickstart-data --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

mkdir -p /tmp/quickstart/file
seq 1000 > /tmp/quickstart/file/input.txt

export CONNECT_HOST=connect
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"name": "quickstart-file-source", "config": {"connector.class":"org.apache.kafka.connect.file.FileStreamSourceConnector", "tasks.max":"1", "topic":"quickstart-data", "file": "/tmp/quickstart/input.txt"}}' \
  http://$CONNECT_HOST:8083/connectors

curl -X GET http://$CONNECT_HOST:8083/connectors/quickstart-file-source/status

kafka-console-consumer --bootstrap-server kafka0:9090 --topic quickstart-data --new-consumer --from-beginning --max-messages 10

curl -X POST -H "Content-Type: application/json" \
    --data '{"name": "quickstart-file-sink", "config": {"connector.class":"org.apache.kafka.connect.file.FileStreamSinkConnector", "tasks.max":"1", "topics":"quickstart-data", "file": "/tmp/quickstart/output.txt"}}' \
    http://$CONNECT_HOST:8083/connectors

curl -s -X GET http://$CONNECT_HOST:8083/connectors/quickstart-file-sink/status

cat /tmp/quickstart/file/output.txt

