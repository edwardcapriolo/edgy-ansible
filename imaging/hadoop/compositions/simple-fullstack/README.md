Simple fullstack
=======

This composition runs the hadoop components (nn, dn, rm, nm)
* fully networked
* no redundancy

Helpful URL(s)
=======
http://localhost:9870/dfshealth.html#tab-datanode

Extra
============

The namenode gets formatted by the use of the special.sh passthrough script:

```
  nn1:
    image: tiny-hdfs:latest
    hostname: nn1
    container_name: nn1
    environment:
      - "JAVA_HOME=/usr"
      - "HADOOP_LOG_DIR=/tmp/nn1logs"
      - "SPECIAL_MAYBE_FORMAT_LOCAL_NN=true"
    entrypoint: "/opt/edgy/bin/special.sh"
    command: [ "/opt/hadoop/bin/hdfs", "namenode" ]
```