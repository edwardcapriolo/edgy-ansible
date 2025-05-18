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
- 3x journalnode
- 2x datanode
- 2x nodemanager

# Scale down (overhead)
Normally the datanode and nodemanager components are run on tens, 
hundreds, or even thousands of servers. In those setups overhead such as 16GB ram to run
2 namenode(s) is an afterthought. For the small 3-node type setup applications will not get much "scale out".
In those cases it is ok to start small (like 2GB) heap for each component. Later on be ready to move components to 
dedicated hardware and more generous CPU/RAM allocations 



