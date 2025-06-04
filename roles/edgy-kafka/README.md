# edgy-kafka

A kafka installation.

Featuring:

- Client Server SSL communications ONLY (no clear text no SASL)
- Internode SSL communications ONLY
- Rack awareness

### Getting started ###

As per usual divide the configuration elements across host and group files.

Group vars
```
kafka_brokers:
- "fedora"

kafka_data_dir: /home/edgy/edgy-kafka/var

kafka_zookeeper:
  - { host: "fedora", port: 2182 }
```

Per host vars
```
### start: edgy-kafka ###
apache_kafka_home: /home/edgy/edgy-kafka
kafka_broker_id: 100
kafka_rack: "/availability-zone-1"
kafka_keystore_location: fedora.jks
kafka_keystore_password: xxxx
kafka_server_cn: "CN=fedora"
kafka_truststore_location: "myTruststore.jks"
kafka_truststore_password: xxxx
### end: edgy-kafka
```

Then kick the install script!

```
sh examples/install-edgy-kafka.sh
```

### Running

```
edgy@fedora:~/edgy-kafka/kafka_2.12-3.9.1/bin$ pwd
/home/edgy/edgy-kafka/kafka_2.12-3.9.1/bin
edgy@fedora:~/edgy-kafka/kafka_2.12-3.9.1/bin$ ./kafka-server-start.sh ../config/server.properties
...
[2025-06-04 11:28:40,849] INFO Kafka startTimeMs: 1749050920833 (org.apache.kafka.common.utils.AppInfoParser)
[2025-06-04 11:28:40,853] INFO [KafkaServer id=100] started (kafka.server.KafkaServer)
[2025-06-04 11:28:41,288] INFO [zk-broker-100-to-controller-forwarding-channel-manager]: Recorded new ZK controller, from now on will use node fedora:9093 (id: 100 rack: /availability-zone-1) (kafka.server.NodeToControllerRequestThread)
[2025-06-04 11:28:41,288] INFO [zk-broker-100-to-controller-alter-partition-channel-manager]: Recorded new ZK controller, from now on will use node fedora:9093 (id: 100 rack: /availability-zone-1) (kafka.server.NodeToControllerRequestThread)

```
