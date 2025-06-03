pushd "{{ apache_zookeeper_home }}/apache-zookeeper-{{ apache_zookeeper_version }}-bin/conf"
source ./arizona-keeper-server-env.sh
./zkServer.sh "$@"
