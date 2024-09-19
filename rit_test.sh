


read -rp "Enter PRIVKEY: " PRIVKEY
read -rp "Enter RPC: " RPC_HTTP
read -rp "Enter Contract_ID: " CTR_ID
read -rp "Enter Contract_Address: " CTR_ADDR


git clone https://github.com/ritual-net/infernet-container-starter
cd ~/infernet-container-starter/projects/hello-world/container
make build

cd ~/infernet-container-starter/deploy
sed -ie "s|ritualnetwork/infernet-node:latest|ritualnetwork/infernet-node:1.0.0|" docker-compose.yaml
wget -O  config.json https://raw.githubusercontent.com/JeTr1x/stafi/main/rit_new_baseconf.json
sed -ie 's|"private_key": "",|"private_key": "'"$PRIVKEY"'",|' config.json
sed -ie 's|"https://base-rpc.publicnode.com"|"'"$RPC_HTTP"'"|' config.json
sed -ie 's|"id": "hello-world",|"id": "'"$CTR_ID"'",|' config.json

docker compose up -d
