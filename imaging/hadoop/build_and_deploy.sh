mvn package -Pnative -Dmaven.skip.test=true -DskipTests -Dtar                                                                                               
cp target/native/target/usr/local/bin/container-executor /usr/local/bin/                                                                                    
chmod 6050 /usr/local/bin/container-executor                                                                                                                
chgrp hadoop /usr/local/bin/container-executor                                                                                                              
chmod 6050 /usr/local/bin/container-executor                                                                                                                
/usr/local/bin/container-executor nobody nobody 0 application_1766935260716_0004  container_1766935260716_0004_02_000001 /yarn-root/nm-local-dir/nmPrivate/c
