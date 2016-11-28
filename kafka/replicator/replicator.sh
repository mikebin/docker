#!/bin/bash

docker run \
  --net=host \
  --rm confluentinc/cp-kafka:3.1.1 \
  kafka-topics --create --topic foo --partitions 3 --replication-factor 2 --if-not-exists --zookeeper localhost:22181

docker run \
  --net=host \
  --rm confluentinc/cp-kafka:3.1.1 \
  kafka-topics --describe --topic foo --zookeeper localhost:22181

docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:3.1.1 \
  bash -c "seq 1000 | kafka-console-producer --request-required-acks 1 --broker-list localhost:9092 --topic foo && echo 'Produced 1000 messages.'"

docker-compose exec connect-host-1 curl -X POST \
     -H "Content-Type: application/json" \
     --data '{
        "name": "replicator-src-a-foo",
        "config": {
          "connector.class":"io.confluent.connect.replicator.ReplicatorSourceConnector",
          "key.converter": "io.confluent.connect.replicator.util.ByteArrayConverter",
          "value.converter": "io.confluent.connect.replicator.util.ByteArrayConverter",
          "src.zookeeper.connect": "localhost:22181",
          "src.kafka.bootstrap.servers": "localhost:9092",
          "dest.zookeeper.connect": "localhost:42181",
          "topic.whitelist": "foo",
          "topic.rename.format": "${topic}.replica"}}'  \
     http://localhost:28082/connectors

docker-compose exec connect-host-1 curl -X GET http://localhost:28082/connectors/replicator-src-a-foo/status

docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:3.1.1 \
  kafka-console-consumer --bootstrap-server localhost:9072 --topic foo.replica --new-consumer --from-beginning --max-messages 1000

docker run \
  --net=host \
  --rm confluentinc/cp-kafka:3.1.1 \
  kafka-topics --describe --topic foo.replica --zookeeper localhost:42181

docker run \
  --net=host \
  --rm confluentinc/cp-kafka:3.1.1 \
  kafka-topics --create --topic bar --partitions 3 --replication-factor 2 --if-not-exists --zookeeper localhost:32181

docker run \
  --net=host \
  --rm confluentinc/cp-kafka:3.1.1 \
  kafka-topics --describe --topic bar --zookeeper localhost:32181

docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:3.1.1 \
  bash -c "seq 1000 | kafka-console-producer --request-required-acks 1 --broker-list localhost:9082 --topic bar && echo 'Produced 1000 messages.'"

docker-compose exec connect-host-1 curl -X POST \
     -H "Content-Type: application/json" \
     --data '{
        "name": "replicator-src-b-bar",
        "config": {
          "connector.class":"io.confluent.connect.replicator.ReplicatorSourceConnector",
          "key.converter": "io.confluent.connect.replicator.util.ByteArrayConverter",
          "value.converter": "io.confluent.connect.replicator.util.ByteArrayConverter",
          "src.zookeeper.connect": "localhost:32181",
          "src.kafka.bootstrap.servers": "localhost:9082",
          "dest.zookeeper.connect": "localhost:42181",
          "topic.whitelist": "bar",
          "topic.rename.format": "${topic}.replica"}}'  \
     http://localhost:28082/connectors

docker-compose exec connect-host-1 curl -X GET http://localhost:28082/connectors/replicator-src-b-bar/status

docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:3.1.1 \
  kafka-console-consumer --bootstrap-server localhost:9072 --topic bar.replica --new-consumer --from-beginning --max-messages 1000

docker run \
  --net=host \
  --rm confluentinc/cp-kafka:3.1.1 \
  kafka-topics --describe --topic bar.replica --zookeeper localhost:42181

