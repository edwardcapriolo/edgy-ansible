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

# High Level HDFS HA Setup

This is the high level list of tasks. This seems like many steps, but some steps
are a simple as running a single playbook

- Configure host and group files
- run install play which makes binaries and templates configuration files 
- start all journal nodes 
- format a single namenode 
- "format" zookeeper data to create entries for failover 
- start namenode and zkfc
- start all datanodes

# Detailed HDFS HA Setup

Let's define the 'fake distributed' setup. All the components are running in different processes. All processes are 
running on a single host. In a production environment multiple components would be deployed across 
multiple hosts.

The role has default configuration options however some variables must be set.

hosts/LOCAL/fedora.yml

```
apache_hadoop_home: /home/edgy/arizona-storage-compute
dfs_clustername: fs_abc

hadoop_env_append:
  - "export JAVA_HOME=/usr"
# Controls the system use that can run the namenode
  - "export HDFS_NAMENODE_USER=edgy"

journalnode_personality: True
...
```

hosts/local/group_vars/arizona_storage_compute.yaml

Note: hadoop wont do the HA namenode with a single node in the configuration. Thus we created
a fake node called "other". It doest not need to exists.
```
namenodes:
- { shortname: "fedora" , host: "fedora" }
- { shortname: "other" , host: "other" }
journalnodes:
- { host: "fedora", port: 8485 }
zookeeper:
- { host: "fedora", port: 2182 }
```
Because this is a "single node" installation we did not need to separate the configuration across host_vars and 
group_vars.

The install playbook puts all the binaries and configurations in place
```
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

Next, there DOES exist a one-time setup script, but it is likely easier to run the steps
one at a time to "supervise" it.

```
cat examples/install-arizona-store-compute-one-time.sh
...
ansible-playbook -v arizona_storage_compute_local.yml -i hosts/LOCAL/hosts \
--extra-vars "operation=journalnode_service hostname=arizona_storage_compute service_command=start"

ansible-playbook -v arizona_storage_compute_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=format_namenode hostname=arizona_storage_compute"

```
To run the failover controller you must initialize its zookeeper state

```
$ bin/hdfs zkfc -formatZK
...
2025-05-28 08:56:54,458 INFO ha.ActiveStandbyElector: Session connected.
===============================================
The configured parent znode /hadoop-ha/fsabc already exists.
Are you sure you want to clear all failover information from
ZooKeeper?
WARNING: Before proceeding, ensure that all HDFS services and
failover controllers are stopped!
===============================================
Proceed formatting /hadoop-ha/fsabc? (Y or N) n
```
If you are curious about the data that was created:

```
edgy@fedora:~/arizona-keeper/apache-zookeeper-3.9.3-bin/bin$ sh arizona-keeper-zkCli.sh -server fedora:2182
[zk: fedora:2182(CONNECTED) 0] ls /
[hadoop-ha, zookeeper]
[zk: fedora:2182(CONNECTED) 1] ls /hadoop-ha 
[fsabc]
[zk: fedora:2182(CONNECTED) 2] ls /hadoop-ha/fsabc 
[ActiveBreadCrumb, ActiveStandbyElectorLock]
```

Once you have formatted the NN it is a good idea to start it in the foregound one time
```
$ edgy@fedora:~/arizona-storage-compute/hadoop-3.4.1$ bin/hdfs namenode
...
2025-05-28 09:18:05,278 INFO namenode.NameNode: NameNode RPC up at: fedora/192.168.5.39:8020.
2025-05-28 09:18:05,282 INFO namenode.FSNamesystem: Starting services required for standby state
2025-05-28 09:18:05,298 INFO ha.EditLogTailer: Will roll logs on active node every 120 seconds.
2025-05-28 09:18:05,319 INFO ha.StandbyCheckpointer: Starting standby checkpoint thread...
Checkpointing active NN to possible NNs: [http://other:9870]
Serving checkpoints at http://fedora:9870
```



### NameNode start


After the initial prep we should be able to kick up all components from a single script.
```
edward@fedora:~/edgy-ansible$ sh examples/service-arizona-storage-compute.sh start
PLAY [arizona_storage_compute] ******************************************************************************************************************************************
PLAY RECAP **************************************************************************************************************************************************************
...
fedora                     : ok=3    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0  

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







