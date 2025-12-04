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
FROM alpine:3.21.2
RUN apk add --no-cache openjdk17-jre-headless
RUN apk add --no-cache bash
RUN mkdir /livy
RUN mkdir -p /livy/conf
RUN mkdir -p /livy/bin
RUN mkdir -p /livy/jars
RUN mkdir -p /livy/repl_2.12-jars
RUN mkdir -p /livy/rsc-jars

COPY apache-livy-bin /livy
WORKDIR /livy
ENTRYPOINT ["/livy/bin/livy-server"]
##bin  conf  DISCLAIMER  jars  LICENSE  NOTICE  repl_2.12-jars  rsc-jars
#edward@fedora:~/edgy-ansible/imaging/incubator-livy/assembly/target/apache-livy-0.10.0-incubating-SNAPSHOT_2.12-bin$
##
EOF

docker build \
--no-cache \
-t livy .
