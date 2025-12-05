./inc.sh
if [ ! -d "incubator-livy" ]; then
  git clone https://github.com/edwardcapriolo/incubator-livy.git
  cd incubator-livy
  mvn package -DskipTests=true --projects '!python-api'
  cd ..
fi

rm -rf apache-livy-bin
cp incubator-livy/assembly//target/apache-livy-0.10.0-incubating-SNAPSHOT_2.12-bin.zip .
unzip apache-livy-0.10.0-incubating-SNAPSHOT_2.12-bin.zip
mv apache-livy-0.10.0-incubating-SNAPSHOT_2.12-bin apache-livy-bin

cat << EOF > Dockerfile
FROM jre-17 AS livy
#FROM alpine:3.21.2
#RUN apk add --no-cache openjdk17-jre-headless
RUN apk add --no-cache bash
RUN mkdir /livy
RUN mkdir /livy/logs
COPY apache-livy-bin /livy
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

