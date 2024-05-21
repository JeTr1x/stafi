

read -p "Enter node name: " INITIA_MONIK
echo 'export INITIA_MONIK='$INITIA_MONIK >> $HOME/.bash_profile
netstat -tulpn | grep 657
read -p "Enter portnum (10-64): " INITIA_PORT
echo 'export INITIA_PORT='$INITIA_PORT >> $HOME/.bash_profile



sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade

sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.21.10.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)



cd $HOME
rm -rf initia
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.15
make install


initiad config set client chain-id initiation-1
initiad config set client keyring-backend test
initiad config set client node tcp://localhost:17957

initiad init $INITIA_MONIK --chain-id initiation-1

curl -Ls https://snapshots.kjnodes.com/initia-testnet/genesis.json > $HOME/.initia/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/initia-testnet/addrbook.json > $HOME/.initia/config/addrbook.json

sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@initia-testnet.rpc.kjnodes.com:17959\"|" $HOME/.initia/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.15uinit,0.01uusdc\"|" $HOME/.initia/config/app.toml
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.initia/config/app.toml
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.initia/config/config.toml



sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${INITIA_PORT}958\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${INITIA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${INITIA_PORT}960\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${INITIA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${INITIA_PORT}966\"%" $HOME/.initia/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:${INITIA_PORT}917\"%; s%^address = \":8080\"%address = \":${INITIA_PORT}980\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:${INITIA_PORT}990\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${INITIA_PORT}991\"%; s%:8545%:${INITIA_PORT}945%; s%:8546%:${INITIA_PORT}946%; s%:6065%:${INITIA_PORT}965%" $HOME/.initia/config/app.toml



sudo tee /etc/systemd/system/initia.service > /dev/null << EOF
[Unit]
Description=Initia node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which initiad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable initia.service

sudo systemctl start initia.service
sleep 30
sudo systemctl stop initia
cp $HOME/.initia/data/priv_validator_state.json $HOME/.initia/priv_validator_state.json.backup
initiad tendermint unsafe-reset-all --home $HOME/.initia --keep-addr-book
sed -i -e 's|^seeds *=.*|seeds = "2eaa272622d1ba6796100ab39f58c75d458b9dbc@34.142.181.82:26656,c28827cb96c14c905b127b92065a3fb4cd77d7f6@testnet-seeds.whispernode.com:25756,cd69bcb00a6ecc1ba2b4a3465de4d4dd3e0a3db1@initia-testnet-seed.itrocket.net:51656,093e1b89a498b6a8760ad2188fbda30a05e4f300@35.240.207.217:26656,2c729d33d22d8cdae6658bed97b3097241ca586c@195.14.6.129:26019"|' $HOME/.initia/config/config.toml
curl -L https://snapshots-testnet.nodejumper.io/initia-testnet/addrbook.json > $HOME/.initia/config/addrbook.json

STATE_SYNC_RPC=https://testnet.initia.rpc.liveraven.net:443
STATE_SYNC_PEER=7c6220827ac7a331400bbdc826014b50a7818c7a@23.88.5.169:33656
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $SYNC_BLOCK_HEIGHT $SYNC_BLOCK_HASH

sed -i \
    -e "s|^enable *=.*|enable = true|" \
    -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
    -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
    -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
    -e "s|^persistent_peers *=.*|persistent_peers = \"$STATE_SYNC_PEER\"|" \
    $HOME/.initia/config/config.toml

mkdir -p $HOME/.initia/data && mv $HOME/.initia/priv_validator_state.json.backup $HOME/.initia/data/priv_validator_state.json

sudo systemctl start initia
sudo journalctl -u initia -fn 100 -o cat



