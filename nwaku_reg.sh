#!/bin/bash

cd nwaku-compose
SLPRND=$(echo $(( RANDOM % 36000 )))
echo "Sleeping 7 hours seconds and" $SLPRND "seconds after"
sleep 25200
sleep $SLPRND
./register_rln.sh
docker compose down && docker compose up -d
docker compose logs -f nwaku
