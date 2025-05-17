# arizona-storage-compute

Arizona provides object storage and compute. 

# Why not X,Y, or Z
Cloudera manager, EMR, XYZ. All great! Arizona is focused on simplicity. 


### Prerequisites

- Java
- Zookeeper

### Object Storage (HDFS)

HDFS provides a distributed, redundant, highly available user space filesystem.

This playbook provisions:
- Redundant high availability Namenode
- Redundant Journal (No SPOF such as NAS)
- Configurable data distribution via rack awareness



