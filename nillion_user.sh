#!/bin/bash

echo -e "\033[1;36m"
echo " ::::::'##:'########:'########:'########::'####:'##::::'## ";
echo " :::::: ##: ##.....::... ##..:: ##.... ##:. ##::. ##::'## ";
echo " :::::: ##: ##:::::::::: ##:::: ##:::: ##:: ##:::. ##'## ";
echo " :::::: ##: ######:::::: ##:::: ########::: ##::::. ### ";
echo " '##::: ##: ##...::::::: ##:::: ##.. ##:::: ##:::: ## ## ";
echo "  ##::: ##: ##:::::::::: ##:::: ##::. ##::: ##::: ##:. ## ";
echo " . ######:: ########:::: ##:::: ##:::. ##:'####: ##:::. ## ";
echo " :......:::........:::::..:::::..:::::..::....::..:::::..::";
echo -e "\e[0m"

sleep 1
read -p "Enter node name: " NILLION_MONIK
CHAIN_ID="nillion-chain-testnet-1"
netstat -tulpn | grep 657
read -p "Enter portnum (10-64): " NILLION_PORT


wget http://88.99.208.54:1433/nilliond
chmod +x nilliond
mkdir $HOME/.local/bin
mv nilliond $HOME/.local/bin/nilliond
source .profile
nilliond version
sleep 2

cd $HOME
nilliond init $NILLION_MONIK --chain-id $CHAIN_ID
nilliond config set client chain-id $CHAIN_ID
nilliond config set client keyring-backend os
nilliond config set client node tcp://localhost:${NILLION_PORT}657

rm ~/.nillionapp/config/genesis.json ~/.nillionapp/config/addrbook.json
wget -P ~/.nillionapp/config http://88.99.208.54:1433/genesis.json
wget -P ~/.nillionapp/config http://88.99.208.54:1433/addrbook.json

rm -rf ~/.nillionapp/data
curl -L http://88.99.208.54:1433/nillion_snap.tar.gz | tar -xzf - -C $HOME/.nillionapp



PEERS="ce05aec98558f9a8289f983b083badf9d37e4d44@141.95.35.110:56316,c59dff7e20c675fe4f76162e9886dcca9b5104ce@135.181.238.38:28156" && \
SEEDS="" && \
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nillionapp/config/config.toml
# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "10"|' \
  $HOME/.nillionapp/config/app.toml


sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NILLION_PORT}958\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NILLION_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NILLION_PORT}960\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NILLION_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NILLION_PORT}966\"%" $HOME/.nillionapp/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:${NILLION_PORT}917\"%; s%^address = \":8080\"%address = \":${NILLION_PORT}980\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:${NILLION_PORT}990\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NILLION_PORT}991\"%; s%:8545%:${NILLION_PORT}945%; s%:8546%:${NILLION_PORT}946%; s%:6065%:${NILLION_PORT}965%" $HOME/.nillionapp/config/app.toml
sed -i '/\[rpc\]/,/\[/{s/^laddr = "tcp:\/\/127\.0\.0\.1:/laddr = "tcp:\/\/0.0.0.0:/}' $HOME/.nillionapp/config/config.toml

tee $HOME/.nillionapp/validator.json > /dev/null <<EOF
{
        "pubkey": $(nilliond tendermint show-validator),
        "amount": "unil",
        "moniker": "$NILLION_MONIK",
        "identity": "",
        "website": "",
        "security": "",
        "details": "",
        "commission-rate": "0.1",
        "commission-max-rate": "0.2",
        "commission-max-change-rate": "0.01",
        "min-self-delegation": "1"
}
EOF
