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
read -p "Enter node name: " ALLORA_MONIK
echo 'export ALLORA_MONIK='$ALLORA_MONIK >> $HOME/.bash_profile
CHAIN_ID="edgenet"
netstat -tulpn | grep 657
read -p "Enter portnum (10-64): " ALLORA_PORT
echo 'export ALLORA_PORT='$ALLORA_PORT >> $HOME/.bash_profile


wget http://88.99.208.54:1433/allorad_v0.2.3.tar.gz
tar xvzf allorad_v0.2.3.tar.gz
mv allorad_v0.2.3 /usr/local/bin/allorad
allorad version
sleep 1

cd $HOME
allorad init $NILLION_MONIK --chain-id $CHAIN_ID
allorad config set client chain-id $CHAIN_ID
allorad config set client keyring-backend test
allorad config set client node tcp://localhost:${NILLION_PORT}657

rm ~/.allorad/config/genesis.json ~/.allorad/config/addrbook.json
wget -P ~/.allorad/config http://88.99.208.54:1433/genesis.json
wget -P ~/.allorad/config http://88.99.208.54:1433/addrbook.json

#rm -rf ~/.allorad/data
#curl -L  | tar -xvzf - -C $HOME/.allorad



PEERS="7f47aec3539715a70853589bd7ef8d2fd7995122@34.224.166.207:32031,b3665ef7fb563be62e79816dd8613e732efcd447@54.81.195.244:32021" && \
SEEDS="" && \
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.allorad/config/config.toml
# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "10"|' \
  $HOME/.allorad/config/app.toml


sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NILLION_PORT}958\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NILLION_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NILLION_PORT}960\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NILLION_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NILLION_PORT}966\"%" $HOME/.allorad/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:${NILLION_PORT}917\"%; s%^address = \":8080\"%address = \":${NILLION_PORT}980\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:${NILLION_PORT}990\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NILLION_PORT}991\"%; s%:8545%:${NILLION_PORT}945%; s%:8546%:${NILLION_PORT}946%; s%:6065%:${NILLION_PORT}965%" $HOME/.allorad/config/app.toml
sed -i '/\[rpc\]/,/\[/{s/^laddr = "tcp:\/\/127\.0\.0\.1:/laddr = "tcp:\/\/0.0.0.0:/}' $HOME/.allorad/config/config.toml

sudo tee $HOME/.allorad/validator.json > /dev/null <<EOF
{
        "pubkey": $(allorad tendermint show-validator),
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


sudo tee /etc/systemd/system/allorad.service > /dev/null <<EOF
[Unit]
Description=Allorad Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which allorad) start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload && \
sudo systemctl enable allorad && \
sudo systemctl restart allorad && \
sudo journalctl -u allorad -f -o cat
