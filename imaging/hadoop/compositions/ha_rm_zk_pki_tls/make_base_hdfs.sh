docker run --network ha_rm_zk_pki_tls \
--user hdfs \
-e JAVA_HOME=/usr \
-e HADOOP_CONFIG_DIR=/hd_conf \
-v ./hd_conf:/hd_conf:ro \
-it --entrypoint /bin/bash tiny-hdfs -c  \
"/opt/hadoop/bin/hdfs dfs -mkdir hdfs://nn1/user ; /opt/hadoop/bin/hdfs dfs -chmod 755 hdfs://nn1/user ; /opt/hadoop/bin/hdfs dfs -mkdir hdfs://nn1/user/auser ; /opt/hadoop/bin/hdfs dfs -chown auser hdfs://nn1/user/auser"