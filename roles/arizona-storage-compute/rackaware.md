## Brief overview

Hadoop offers rack awareness (https://hadoop.apache.org/docs/r3.4.1/hadoop-project-dist/hadoop-common/RackAwareness.html#bash_Example). With distributed systems
performance is often closely tied to data and compute locality. It is very important to consider the impact node 
allocations. Simply put a misconfiguration could result in data loss or calls from network operation if a job inadvertently
saturates a network link!

## arizona implementation

A data file
```
edgy@fedora:~/arizona-storage-compute/hadoop-3.4.1$ cat etc/hadoop/topology.data 
fedora    /availability-zone-1
```


A shell script to read the file
```
HADOOP_CONF=/home/edgy/arizona-storage-compute/hadoop-3.4.1/etc/hadoop

while [ $# -gt 0 ] ; do
  NARG=$1
  exec< ${HADOOP_CONF}/topology.data
  RES=""
  while read line ;do
...
```

How it works in practice
```
edgy@fedora:~/arizona-storage-compute/hadoop-3.4.1$ sh etc/hadoop/topology.sh fedora
/default-rack edgy@fedora:~/arizona-storage-compute/hadoop-3.4.1$ sh etc/hadoop/topology.sh fedora server2 server3
/default-rack /default-rack /default-rack edgy@fedora:~/arizona-storage-compute/hadoop-3.4.1$ 

```

How it is stitched into the configuration core-site.xml

```
  <property>
    <name>net.topology.script.file.name</name>
    <value>{{ apache_hadoop_home }}/hadoop-{{ apache_hadoop_version }}/etc/hadoop/topology.sh</value>
  </property>
```

How to configure:

Ansible sources configuration options from defaults/groupvar/allvar/hostvars. Hostvar is the highest level before the command 
line so landing the correct option in correct place gets it done!
```
hadoop_rack: "/availability-zone-1"
```

