
### entrypoint 

The entry point is bin/arizona-keeper-zkServer.sh. 

```
edgy@fedora:~/arizona-keeper/apache-zookeeper-3.9.3-bin/bin$ ./arizona-keeper-zkServer.sh start-foreground | head -3
/usr/bin/java
ZooKeeper JMX enabled by default
Using config: /home/edgy/arizona-keeper/apache-zookeeper-3.9.3-bin/bin/../conf/zoo.cfg
08:57:33.538 [main] INFO org.apache.zookeeper.server.quorum.QuorumPeerConfig - Reading configuration from: /home/edgy/arizona-keeper/apache-zookeeper-3.9.3-bin/bin/../conf/zoo.cfg
08:57:33.552 [main] INFO org.apache.zookeeper.server.quorum.QuorumPeerConfig - clientPortAddress is 0.0.0.0:2181
```

Once you get the server running the client will connect

```declarative
./arizona-keeper-zkCli.sh -server fedora:2182
[zk: fedora:2182(CONNECTED) 0] ls /
09:50:25.005 [main] DEBUG org.apache.zookeeper.ZooKeeperMain - Processing ls
09:50:25.041 [zkNetty-EpollEventLoopGroup-1-1] DEBUG org.apache.zookeeper.ClientCnxn - Reading reply session id: 0x10000ef99240000, packet:: clientPath:null serverPath:null finished:false header:: 1,12  replyHeader:: 1,1,0  request:: '/,F  response:: v{'zookeeper},s{0,0,0,0,0,-1,0,0,0,1,0}
[zookeeper]
[zk: fedora:2182(CONNECTED) 1] 09:50:35.022 [zkNetty-EpollEventLoopGroup-1-1] DEBUG org.apache.zookeeper.ClientCnxn - Got ping response for session id: 0x10000ef99240000 after 8ms.

```