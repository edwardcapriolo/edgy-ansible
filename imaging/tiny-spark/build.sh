./inc.sh

if [ ! -d "spark-3.5.7-bin-hadoop3" ]; then
  curl https://dlcdn.apache.org/spark/spark-3.5.7/spark-3.5.7-bin-hadoop3.tgz
  tar -xf spark-3.5.7-bin-hadoop3.tgz 
fi

rm spark-3.5.7-bin-hadoop3/yarn/spark-3.5.7-yarn-shuffle.jar
rm spark-3.5.7-bin-hadoop3/jars/rocksdbjni-8.3.2.jar
rm spark-3.5.7-bin-hadoop3/python/*
rm spark-3.5.7-bin-hadoop3/R/*

cat << EOF > Dockerfile
FROM jre-17
RUN apk add --no-cache bash
RUN mkdir /opt/spark
COPY spark-3.5.7-bin-hadoop3 /opt/spark 
WORKDIR /opt/spark
ENTRYPOINT ["/opt/spark/bin/spark-shell"]
EOF

docker build \
--no-cache \
-t tiny-spark .
