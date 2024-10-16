#!/bin/bash

docker rm -f dspace7 || true > /dev/null 2>&1
docker rm -f dspace7db || true > /dev/null 2>&1
docker rm -f dspace7solr || true > /dev/null 2>&1


docker rmi -f ibict/postgresdspace7 || true > /dev/null 2>&1
docker rmi -f solr:8.11-slim || true > /dev/null 2>&1



docker compose -f docker-compose_restart.yml up --build -d
