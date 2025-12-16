./inc.sh
if [ ! -d "incubator-livy" ]; then
  git clone https://github.com/edwardcapriolo/incubator-livy.git
  cd incubator-livy
  mvn package -DskipTests=true --projects '!python-api'
  cd ..
fi

#rebuild
#cd incubator-livy
#mvn package -DskipTests=true --projects '!python-api'
#cd ..

rm -rf apache-livy-bin
cp incubator-livy/assembly//target/apache-livy-0.10.0-incubating-SNAPSHOT_2.12-bin.zip .
unzip apache-livy-0.10.0-incubating-SNAPSHOT_2.12-bin.zip
mv apache-livy-0.10.0-incubating-SNAPSHOT_2.12-bin apache-livy-bin

cat << EOF > Dockerfile
FROM ecapriolo/jre-17:0.0.1 AS livy
RUN apk add --no-cache python3 bash

RUN addgroup -S livy && adduser -S -G livy -H -D livy 
RUN mkdir /livy
RUN mkdir /livy/logs && chown livy:livy /livy/logs
COPY apache-livy-bin /livy

USER livy
WORKDIR /livy
ENTRYPOINT ["/livy/bin/livy-server"]

FROM livy AS livy-and-tiny-spark
COPY --from=ecapriolo/tiny-spark:3.5.7-2 /opt/spark /opt/spark
#COPY --from=tiny-spark:latest /opt/spark /opt/spark
COPY debug_log4j.properties /livy/conf/log4j.properties

EOF

docker build \
--no-cache \
--target livy-and-tiny-spark \
-t livy-and-tiny-spark .


docker build \
--no-cache \
--target livy \
-t livy .

