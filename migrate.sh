#! /bin/bash

dir=${PWD##*/}
db_name=${dir}_postgres_1
network_name=${dir}_default

docker-compose up -d postgres; sleep 3
docker run --rm \
    --network ${network_name} \
    --link ${db_name}:${db_name} \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=${db_name}" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=${db_name}" \
    kong:ubuntu kong migrations bootstrap

# backup
#pg_dump -U kong -d kong -f dump.sql

# restore
#psql -U kong -d kong -f dump.sql

