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

### Policy as code topic creation and access control

We also handle topic creation and ACL creation

```declarative
topic_configuration:
  - { topic: "topic1", acl_list: [
   { operation: "read", principal: "bob" }
      ]
    }
```

```declarative
edward@fedora:~/edgy-ansible$ sh examples/install-edgy-kafka-topic-configuration.sh 
Using /etc/ansible/ansible.cfg as config file

PLAY [edgy_kafka] ************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************
[WARNING]: Platform linux on host fedora is using the discovered Python interpreter at /usr/bin/python3.13, but future installation of another Python interpreter could change the meaning of that
path. See https://docs.ansible.com/ansible-core/2.18/reference_appendices/interpreter_discovery.html for more information.
ok: [fedora]

TASK [include_role : edgy-kafka] *********************************************************************************************************************************************************************
included: edgy-kafka for fedora

TASK [edgy-kafka : Set zookeeper connection string] **************************************************************************************************************************************************
ok: [fedora] => {"ansible_facts": {"zk_connect": "fedora:2182"}, "changed": false}

TASK [edgy-kafka : Set kafka base path] **************************************************************************************************************************************************************
ok: [fedora] => {"ansible_facts": {"base_path": "/home/edgy/edgy-kafka/kafka_2.12-3.9.1"}, "changed": false}

TASK [edgy-kafka : List currently installed topics] **************************************************************************************************************************************************
changed: [fedora] => {"changed": true, "cmd": ["/home/edgy/edgy-kafka/kafka_2.12-3.9.1/bin/kafka-topics.sh", "--bootstrap-server", "fedora:9093", "--command-config", "/home/edgy/edgy-kafka/kafka_2.12-3.9.1/config/client-config.properties", "--list"], "delta": "0:00:05.374310", "end": "2025-06-04 13:05:00.766957", "msg": "", "rc": 0, "start": "2025-06-04 13:04:55.392647", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}

TASK [edgy-kafka : Create topics not existing] *******************************************************************************************************************************************************
changed: [fedora] => (item={'topic': 'topic1', 'acl_list': [{'operation': 'read', 'principal': 'bob'}]}) => {"ansible_loop_var": "item", "changed": true, "cmd": ["/home/edgy/edgy-kafka/kafka_2.12-3.9.1/bin/kafka-topics.sh", "--create", "--bootstrap-server", "fedora:9093", "--command-config", "/home/edgy/edgy-kafka/kafka_2.12-3.9.1/config/client-config.properties", "--topic", "topic1"], "delta": "0:00:06.180311", "end": "2025-06-04 13:05:08.687989", "item": {"acl_list": [{"operation": "read", "principal": "bob"}], "topic": "topic1"}, "msg": "", "rc": 0, "start": "2025-06-04 13:05:02.507678", "stderr": "", "stderr_lines": [], "stdout": "Created topic topic1.", "stdout_lines": ["Created topic topic1."]}

PLAY RECAP *******************************************************************************************************************************************************************************************
fedora                     : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  


```

Magic!

```declarative
....
.kafka.clients.NetworkClient)
[2025-06-04 13:05:07,974] INFO [ReplicaFetcherManager on broker 100] Removed fetcher for partitions Set(topic1-0) (kafka.server.ReplicaFetcherManager)
[2025-06-04 13:05:08,157] INFO [LogLoader partition=topic1-0, dir=/home/edgy/edgy-kafka/var] Loading producer state till offset 0 with message format version 2 (kafka.log.UnifiedLog$)
[2025-06-04 13:05:08,202] INFO Created log for partition topic1-0 in /home/edgy/edgy-kafka/var/topic1-0 with properties {} (kafka.log.LogManager)
[2025-06-04 13:05:08,208] INFO [Partition topic1-0 broker=100] No checkpointed highwatermark is found for partition topic1-0 (kafka.cluster.Partition)
[2025-06-04 13:05:08,212] INFO [Partition topic1-0 broker=100] Log loaded for partition topic1-0 with initial high watermark 0 (kafka.cluster.Partition)


```