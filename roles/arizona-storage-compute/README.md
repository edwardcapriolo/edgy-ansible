# arizona-storage-compute

Arizona-storage-compute provides object storage (hdfs) and compute (yarn). Intended
for secure production single application use cases.  

# Why not X,Y, or Z
Cloudera manager, EMR, XYZ. All great! Arizona is focused on simplicity. If you know
docker/teraform/ docker-compose/puppet/chef you know how to take a set of steps 
and fit it to your exact environment. Here we focus on a good simple install. 


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




