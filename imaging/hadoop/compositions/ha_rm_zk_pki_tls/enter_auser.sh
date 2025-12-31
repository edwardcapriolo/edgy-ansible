docker run --network ha_rm_1 \
--user auser \
-e JAVA_HOME=/usr \
-e HADOOP_CONF_DIR=/hd_conf \
-v ./hd_conf:/hd_conf:ro \
-v ./pki/pki-shared/:/mnt/pki-shared:ro \
-it --entrypoint /bin/bash tiny-hadoop -c "
/opt/hadoop/bin/hdfs dfs -rmr hdfs://nn1:8020/user/auser/out ;
/opt/hadoop/bin/hadoop dfs -mkdir -p hdfs://nn1/user/auser/in ;
/opt/hadoop/bin/hadoop dfs -copyFromLocal /opt/hadoop/README.txt hdfs://nn1/user/auser/in ;
/opt/hadoop/bin/yarn jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.2.jar wordcount hdfs://nn1/user/auser/in hdfs://nn1/user/auser/out  ;


"