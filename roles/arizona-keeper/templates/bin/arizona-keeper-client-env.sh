ZK_KEYSTORE_LOCATION=../conf/{{ keystore_location }}
ZK_TRUSTSTORE_LOCATION=../conf/{{ truststore_location }}

export CLIENT_JVMFLAGS="
-Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty \
-Dzookeeper.client.secure=true \
-Dzookeeper.ssl.keyStore.location=$ZK_KEYSTORE_LOCATION \
-Dzookeeper.ssl.keyStore.password={{ keystore_password }} \
-Dzookeeper.ssl.trustStore.location=$ZK_TRUSTSTORE_LOCATION \
-Dzookeeper.ssl.trustStore.password={{ truststore_password }}"
