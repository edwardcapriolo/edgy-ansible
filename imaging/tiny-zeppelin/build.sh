.inc.sh

if [ ! -e "zeppelin-0.12.0-bin-all.tgz" ]; then
  curl  https://dlcdn.apache.org/zeppelin/zeppelin-0.12.0/zeppelin-0.12.0-bin-all.tgz -O
  tar -xf zeppelin-0.12.0-bin-all.tgz
fi

rm -rf zeppelin-0.12.0-bin-all/interpreter/alluxio
rm -rf zeppelin-0.12.0-bin-all/interpreter/flink
rm -rf zeppelin-0.12.0-bin-all/interpreter/flink-cmd
rm -rf zeppelin-0.12.0-bin-all/interpreter/influxdb
#show me your not a nosql fanboy
rm -rf zeppelin-0.12.0-bin-all/interpreter/mongodb
rm -rf zeppelin-0.12.0-bin-all/interpreter/neo4j
rm -rf zeppelin-0.12.0-bin-all/interpreter/hbase
rm -rf zeppelin-0.12.0-bin-all/interpreter/neo4j

rm -rf zeppelin-0.12.0-bin-all/interpreter/r
rm -rf zeppelin-0.12.0-bin-all/interpreter/sparql


cat << EOF > Dockerfile

FROM ecapriolo/jre-17:0.0.1 AS zeppelin
RUN apk add --no-cache bash
RUN apk add --no-cache python3 

# py3-pip
COPY zeppelin-0.12.0-bin-all /opt/zeppelin 
WORKDIR /opt/zeppelin
ENTRYPOINT ["/opt/zeppelin/bin/zeppelin.sh"]


FROM zeppelin as zeppelin-and-tiny-spark
COPY --from=ecapriolo/tiny-spark:3.5.7-2 /opt/spark /opt/spark

EOF


docker build \
--no-cache \
--target zeppelin \
-t tiny-zeppelin .

docker build \
--no-cache \
--target zeppelin-and-tiny-spark \
-t tiny-zeppelin-and-tiny-spark .
