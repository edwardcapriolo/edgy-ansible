pushd {{ apache_hadoop_home }}/hadoop-{{ apache_hadoop_version }}

case "$1" in
  start)
    nohup bin/hdfs --daemon start $2
    ;;
  stop)
    nohup bin/hdfs --daemon stop $2
    ;;
  status)
    bin/hdfs --daemon status $2
    ;;
  *)
    echo "Usage: stop COMPONENT_NAME (namenode,datanode, etc)"
    exit 1
    ;;
esac

popd
