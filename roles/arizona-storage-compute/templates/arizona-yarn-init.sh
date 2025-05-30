pushd {{ apache_hadoop_home }}/hadoop-{{ apache_hadoop_version }}

case "$1" in
  start)
    nohup bin/yarn --daemon start $2
    ;;
  stop)
    nohup bin/yarn --daemon stop $2
    ;;
  status)
    bin/yarn --daemon status $2
    ;;
  *)
    echo "Usage: stop COMPONENT_NAME (resourcemanager, nodemanager, etc)"
    exit 1
    ;;
esac

popd
