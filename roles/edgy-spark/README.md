### edgy-spark

Edgy-spark spark configured to work out-of-the box with [arizona-storage-compute](../arizona-storage-compute/README.md). 
This isn't any "magic" arizona is YARN, and a few command line options to spark activates yarn mode.

### configuration

The aftermarket configuration to spark is very small, we customize spark-env.sh to
locate things
```
edgy_spark_home: /home/edgy/edgy_spark
spark_env_append:
  - "export JAVA_HOME=/usr/lib/jvm/temurin-8-jdk"
  - "export SPARK_DIST_CLASSPATH=$({{ apache_hadoop_home }}/hadoop-3.4.1/bin/hadoop classpath)"
  - "export HADOOP_CONF_DIR={{ apache_hadoop_home }}/hadoop-3.4.1/etc/hadoop"

```

Run the install play

```declarative
edward@fedora:~/edgy-ansible$ sh examples/install-edgy-spark.sh
```

### spark-shell 

spark-shell will default to the master local. In YARN mode the master will be a container in the cluster.
```
edgy@fedora:~/edgy_spark/spark-3.4.4-bin-without-hadoop$ bin/spark-shell --master yarn --queue priority
...
2025-05-30 11:03:30,440 INFO repl.Main: Created Spark session
Spark context Web UI available at http://fedora:4040
Spark context available as 'sc' (master = yarn, app id = application_1748605809782_0003).
Spark session available as 'spark'.
2025-05-30 11:03:30,469 INFO cluster.YarnClientSchedulerBackend: Add WebUI Filter. org.apache.hadoop.yarn.server.webproxy.amfilter.AmIpFilter, Map(PROXY_HOSTS -> fedora,other, PROXY_URI_BASES -> http://fedora:8088/proxy/application_1748605809782_0003,http://other:8088/proxy/application_1748605809782_0003, RM_HA_URLS -> null,null), /proxy/application_1748605809782_0003
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.4.4
      /_/
         
Using Scala version 2.12.17 (OpenJDK 64-Bit Server VM, Java 1.8.0_452)
Type in expressions to have them evaluated.
Type :help for more information.

scala> 

```

### common troubleshooting ###


```declarative
2025-05-30 11:02:54,061 INFO yarn.Client: 
	 client token: N/A
	 diagnostics: AM container is launched, waiting for AM container to Register with RM
	 ApplicationMaster host: N/A
	 ApplicationMaster RPC port: -1
	 queue: root.priority
	 start time: 1748617372890
	 final status: UNDEFINED
	 tracking URL: http://fedora:8088/proxy/application_1748605809782_0003/
	 user: edgy
2025-05-30 11:02:55,067 INFO yarn.Client: Application report for application_1748605809782_0003 (state: ACCEPTED)
2025-05-30 11:02:56,074 INFO yarn.Client: Application report for application_1748605809782_0003 (state: ACCEPTED)
2025-05-30 11:02:57,079 INFO yarn.Client: Application report for application_1748605809782_0003 (state: ACCEPTED)
2025-05-30 11:02:58,085 INFO yarn.Client: Application report for application_1748605809782_0003 (state: ACCEPTED)
2025-05-30 11:02:59,091 INFO yarn.Client: Application report for application_1748605809782_0003 (state: ACCEPTED)
```

If you are starting spark-shell and you see the job hang in the ACCEPTED state, that typically means you
have picked a queue with not enough resources or asking for something that can not be provided (nodemanager only has 4GB ram
you are asking for a container with 10GB) the RM UI will help you understand why the job is not starting.