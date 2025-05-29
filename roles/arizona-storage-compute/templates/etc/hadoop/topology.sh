HADOOP_CONF={{ apache_hadoop_home }}/hadoop-{{ apache_hadoop_version }}/etc/hadoop

while [ $# -gt 0 ] ; do
  NARG=$1
  exec< ${HADOOP_CONF}/topology.data
  RES=""
  while read line ;do
    AR=( $line )
    if [ "${AR[0]}" = "$NARG" ]
    then
      RES="${AR[1]}"
    fi
  done
  shift
  if [ -z "$RES" ] ; then
    echo -n "/default-rack "
  else
    echo -n "$RES "
  fi
done