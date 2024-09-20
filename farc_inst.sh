#!/bin/bash

# Prompt for unique values
read -rp "Enter API_KEY: " API_KEY
read -rp "Enter HUB_OPERATOR_FID: " HUB_OPERATOR_FID

git clone https://github.com/farcasterxyz/hub-monorepo.git

# Change directory to the appropriate location
cd hub-monorepo/apps/hubble

# Create or overwrite the .env file with the provided values
cat <<EOL > .env
FC_NETWORK_ID=1
BOOTSTRAP_NODE=/dns/nemes.farcaster.xyz/tcp/2282
STATSD_METRICS_SERVER=statsd:8125
ETH_MAINNET_RPC_URL=https://mainnet.infura.io/v3/$API_KEY
OPTIMISM_L2_RPC_URL=https://optimism-mainnet.infura.io/v3/$API_KEY
HUB_OPERATOR_FID=$HUB_OPERATOR_FID
EOL
PRT=$(echo $(( 100 + ((RANDOM % 899)) )))
sed -ie s"|3000:3000|3${PRT}:3000|" docker-compose.yml


# Run Docker compose to start the services
docker compose run hubble yarn identity create

# Set the necessary permissions
chmod -R 777 .hub .rocks grafana
docker compose run hubble yarn identity create
chmod -R 777 .hub .rocks grafana
docker compose up statsd grafana hubble -d

