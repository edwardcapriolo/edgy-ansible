docker run --network ha_rm_zk_pki_tls \
--user hdfs \
-e JAVA_HOME=/usr \
-e HADOOP_CONF_DIR=/hd_conf \
-v ./hd_conf:/hd_conf:ro \
-v ./pki/pki-shared/:/mnt/pki-shared:ro \
-it --entrypoint /bin/bash tiny-hdfs