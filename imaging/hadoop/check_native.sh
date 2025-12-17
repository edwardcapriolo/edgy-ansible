export JAVA_HOME=/usr
export HADOOP_ROOT_LOGGER=DEBUG,console
export HADOOP_OPTS="$HADOOP_OPTS -Djava.library.path=/usr/local/lib"
/opt/hadoop/bin/hadoop checknative
