HADOOP_CONF={{ apache_hadoop_home }}/hadoop-{{ apache_hadoop_version }}/etc/hadoop

while [ $# -gt 0 ] ; do
  NARG=$1
  exec< ${HADOOP_CONF}/topology.data
  RES=""
  while read line ; do
    #THERE IS ALL types of nastness with space andtab especially because jina might turn a tab into 4 spaces. | is a better choice
    IFS='|'
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