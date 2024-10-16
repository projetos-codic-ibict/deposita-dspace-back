#!/bin/bash

# Maven
echo "Executando Maven"
mkdir ~/.m2 || true
docker run -v ~/.m2:/var/maven/.m2 -v "$(pwd)/source/DSpace-dspace-7.6":/tmp/dspacebuild -w /tmp/dspacebuild -ti --rm -e MAVen_CONFIG=/var/maven/.m2 maven:3.8.6-openjdk-11 mvn -q --no-transfer-progress -Duser.home=/var/maven clean package -P dspace-oai,\!dspace-sword,\!dspace-swordv2,\!dspace-rdf,\!dspace-iiif

# Ant
echo "Executando Ant"
docker run -v ~/.m2:/var/maven/.m2 -v $(pwd)/dspace-install-dir:/dspace -v $(pwd)/source/DSpace-dspace-7.6:/tmp/dspacebuild -w /tmp/dspacebuild -ti --rm -e MAVen_CONFIG=/var/maven/.m2 maven:3.8.6-openjdk-11 /bin/bash -c "wget https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.12-bin.tar.gz && tar -xvzf apache-ant-1.10.12-bin.tar.gz && cd dspace/target/dspace-installer && ../../../apache-ant-1.10.12/bin/ant init_installation update_configs update_code update_webapps && cd ../../../ && rm -rf apache-ant-*"


docker rm -f dspace7 || true > /dev/null 2>&1
docker rm -f dspace7db || true > /dev/null 2>&1
docker rm -f dspace7solr || true > /dev/null 2>&1


docker rmi -f ibict/postgresdspace7 || true > /dev/null 2>&1
docker rmi -f solr:8.11-slim || true > /dev/null 2>&1



docker compose -f docker-compose_restart.yml up --build -d
