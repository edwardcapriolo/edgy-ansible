# arizona-storage-compute

Arizona-storage-compute provides object storage (hdfs) and compute (yarn). Intended
for secure production single application use cases. This role creates a No Single Point Of Failure
(SPOF) setup. Both HDFS and YARN support automatic takeover of the "leaders" or "head-nodes" 
the NameNode and the ResourceManager. 


# Why not X,Y, or Z
Cloudera manager, EMR, XYZ. All great! Arizona is focused on simplicity. If you know
docker/teraform/docker-compose/puppet/chef you know you can "wiggle" all the files in 
hadoop/etc and make them do whatever you want. There are so many files
the flexibility is rather endless.


### Prerequisites

- Java
- Zookeeper

### Object Storage (HDFS)

HDFS provides a distributed, redundant, highly available user space filesystem.

This playbook provisions:
- Redundant high availability Namenode
- Redundant Journal (No SPOF such as NAS)
- Configurable data distribution via rack awareness

### Security

This role is not intended to be used on a public network. The application 
components are not internet-hardened. Perimeter security such as
packet filtering and access control lists should be used
on internal networks as well due to the dynamic nature 
of the hdfs components.

- HDFS components use ssl/tls to communicate with zookeeper

### Full redundancy 
To achieve full redundancy at-least 3 systems are required:

- 3x zookeeper
- 2x namenode (+zkfc)
- 3x journalnode : See https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html
- 2x datanode
- 2x nodemanager

# Scale down (overhead)
Normally the datanode and nodemanager components are run on tens, 
hundreds, or even thousands of servers. In those setups overhead such as 16GB ram to run
2 namenode(s) is an afterthought. For the small 3-node type setup applications will not get much "scale out".
In those cases it is ok to start small (like 2GB) heap for each component. Later on be ready to move components to 
dedicated hardware and more generous CPU/RAM allocations 


# Getting started

### 
```declarative
edward@fedora:~/edgy-ansible$ sh examples/install-arizona-storage-compute.sh
...
TASK [arizona-storage-compute : template etc] ***************************************************************************************************************************
ok: [fedora] => (item={'src': 'etc/hadoop/capacity-scheduler.xml', 'dest': 'hadoop-3.4.1/etc/hadoop/capacity-scheduler.xml', 'mode': '0644'})
changed: [fedora] => (item={'src': 'etc/hadoop/hadoop-env.sh', 'dest': 'hadoop-3.4.1/etc/hadoop/hadoop-env.sh', 'mode': '0644'})
ok: [fedora] => (item={'src': 'etc/hadoop/core-site.xml', 'dest': 'hadoop-3.4.1/etc/hadoop/core-site.xml', 'mode': '0644'})
ok: [fedora] => (item={'src': 'etc/hadoop/hdfs-site.xml', 'dest': 'hadoop-3.4.1/etc/hadoop/hdfs-site.xml', 'mode': '0644'})
ok: [fedora] => (item={'src': 'etc/hadoop/log4j.properties', 'dest': 'hadoop-3.4.1/etc/hadoop/log4j.properties', 'mode': '0644'})

PLAY RECAP **************************************************************************************************************************************************************
fedora                     : ok=12   changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

```

### starting journalnode

First start the journalnode, in the foreground watch it come up once.


```
dgy@fedora:~/arizona-storage-compute/hadoop-3.4.1$ cd /home/edgy/arizona-storage-compute/hadoop-3.4.1/
edgy@fedora:~/arizona-storage-compute/hadoop-3.4.1$ bin/hdfs journalnode start
...
2025-05-23 20:11:35,822 INFO server.JournalNode: RPC server is binding to 0.0.0.0:8485
2025-05-23 20:11:35,884 INFO server.JournalNode: The number of JournalNodeRpcServer handlers is 5.
2025-05-23 20:11:35,928 INFO ipc.CallQueueManager: Using callQueue: class java.util.concurrent.LinkedBlockingQueue, queueCapacity: 500, scheduler: class org.apache.hadoop.ipc.DefaultRpcScheduler, ipcBackoff: false, ipcFailOver: false.
CTRL + C
edgy@fedora:~/arizona-storage-compute/hadoop-3.4.1$ ls ../var/dfs/journalnode/
```







