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

apt install unzip
mkdir -p ~/.morph 
cd ~/.morph
git clone https://github.com/morph-l2/morph.git
cd morph
git checkout v0.1.0-beta
make nccc_geth

cd ~/.morph/morph/node 
make build

cd ~/.morph
wget https://raw.githubusercontent.com/morph-l2/config-template/main/holesky/data.zip
unzip data.zip

cd ~/.morph
openssl rand -hex 32 > jwt-secret.txt

sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:11658\"%; s%^laddr = \"tcp://0.0.0.0:26657\"%laddr = \"tcp://0.0.0.0:11657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:11660\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:11656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":11666\"%" /root/.morph/node-data/config/config.toml



sudo tee /etc/systemd/system/morph_gethd.service >/dev/null <<EOF
[Unit]
Description=Morph Geth
After=network.target
Wants=network.target

[Service]
User=root
WorkingDirectory=/root/.morph
Restart=always
RestartSec=5
TimeoutStopSec=180
ExecStart=/root/.morph/morph/go-ethereum/build/bin/geth  --morph-holesky  --datadir=/root/.morph/geth-data   --http --http.api=web3,debug,eth,txpool,net,engine --http.addr 0.0.0.0 --authrpc.addr localhost  --authrpc.vhosts="localhost"  --authrpc.port 8551  --authrpc.jwtsecret=/root/.morph/jwt-secret.txt  --miner.gasprice="100000000"   --log.filename=/root/.morph/geth.log

[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl enable morph_gethd
systemctl restart morph_gethd


sudo tee /etc/systemd/system/morph_noded.service >/dev/null <<EOF
[Unit]
Description=Morph Node
After=network.target
Wants=network.target

[Service]
User=root
WorkingDirectory=/root/.morph
Restart=always
RestartSec=5
TimeoutStopSec=180
ExecStart=/root/.morph/morph/node/build/bin/morphnode --home /root/.morph/node-data --l2.jwt-secret /root/.morph/jwt-secret.txt  --l2.eth http://localhost:8545  --l2.engine http://localhost:8551  --log.filename /root/.morph/node.log


[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl enable morph_noded
systemctl restart morph_noded
journalctl -fu morph_noded

