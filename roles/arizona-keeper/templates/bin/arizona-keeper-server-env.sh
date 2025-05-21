ZK_KEYSTORE_LOCATION=../conf/{{ keystore_location }}
ZK_KEYSTORE_PASSWORD={{ keystore_password }}
ZK_TRUSTSTORE_LOCATION=../conf/{{ truststore_location }}
ZK_TRUSTSTORE_PASSWORD={{ truststore_password }}

SSL_JVM_FLAGS="-Dzookeeper.serverCnxnFactory=org.apache.zookeeper.server.NettyServerCnxnFactory \
-Dzookeeper.ssl.keyStore.location=$ZK_KEYSTORE_LOCATION \
-Dzookeeper.ssl.keyStore.password=$ZK_KEYSTORE_PASSWORD \
-Dzookeeper.ssl.trustStore.location=$ZK_TRUSTSTORE_LOCATION \
-Dzookeeper.ssl.trustStore.password=$ZK_TRUSTORE_PASSWORD \
-Dzookeeper.ssl.endpoint.identification.algorithm=false "

export SERVER_JVMFLAGS="${SERVER_JVMFLAGS} ${SSL_JVM_FLAGS}"

