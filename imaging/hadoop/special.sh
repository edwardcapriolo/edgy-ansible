#!/bin/sh
if [ -n "$SPECIAL_MAYBE_FORMAT_LOCAL_NN" ]; then
  if [ -e "/hdfs-root/nn" ]; then
    true
  else
    echo "Will attempt to format namenode"
    /opt/hadoop/bin/hdfs namenode -format
  fi
fi

exec "$@"