systemctl stop morph_gethd morph_noded


GO_VERSION="1.22.0"

# Remove any existing Go installation
if [ -d "/usr/local/go" ]; then
    echo "Removing previous Go installation..."
    rm -rf /usr/local/go
fi

# Download the Go binary
echo "Downloading Go $GO_VERSION..."
wget https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz

# Extract the archive
echo "Extracting Go $GO_VERSION..."
tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz

# Clean up by removing the downloaded archive
echo "Cleaning up..."
rm go$GO_VERSION.linux-amd64.tar.gz

# Set up environment variables
echo "Setting up environment variables..."
if ! grep -q "/usr/local/go/bin" /etc/profile; then
    echo "export PATH=\$PATH:/usr/local/go/bin" >> /etc/profile
    echo "export PATH=\$PATH:\$HOME/go/bin" >> /etc/profile
fi

go version


rm -rf 
mkdir -p ~/.morph
cd ~/.morph
git clone https://github.com/morph-l2/morph.git

cd morph
git checkout v0.2.0-beta

make nccc_geth

cd ~/.morph/morph/node || exit
make build

cd ~/.morph || exit
wget https://raw.githubusercontent.com/morph-l2/config-template/main/holesky/data.zip
unzip data.zip

cd ~/.morph || exit
openssl rand -hex 32 > jwt-secret.txt

EXTERNAL_IP=$(wget -qO- eth0.me) \
PROXY_APP_PORT=15658 \
P2P_PORT=15656 \
RPC_PORT=15657 \
# Set PROXY_APP, RPC, PPROF, P2P ports to config.toml
sed -i \
    -e "s/\(proxy_app = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$PROXY_APP_PORT\"/" \
    -e "s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$RPC_PORT\"/" \
    -e "/\[p2p\]/,/^\[/{s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$P2P_PORT\"/}" \
    -e "/\[p2p\]/,/^\[/{s/\(external_address = \"\)\([^:]*\):\([0-9]*\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/; t; s/\(external_address = \"\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/}" \
    /home/ritual/.morph/node-data/config/config.toml
# Set indexer to config.toml
sed -i "s/^indexer *=.*/indexer = \"kv\"/" $HOME/.morph/node-data/config/config.toml
#sed -i "s/moniker = \"my-morph-node\"/moniker = \"$MONIKER\"/" $HOME/.morph/node-data/config/config.toml



## download package
wget -q --show-progress https://snapshot.morphl2.io/holesky/snapshot-20240805-1.tar.gz
## uncompress package
tar -xzvf snapshot-20240805-1.tar.gz

rsync -av --remove-source-files snapshot-20240805-1/geth geth-data
rsync -av --remove-source-files snapshot-20240805-1/data node-data



SU ROOT

sudo tee /etc/systemd/system/morph_gethd.service > /dev/null << EOF
[Unit]
Description=Geth Node Service
After=network.target

[Service]
User=ritual
Group=ritual
ExecStart=/home/ritual/.morph/morph/go-ethereum/build/bin/geth --morph-holesky \
    --datadir /home/ritual/.morph/geth-data \
    --verbosity=3 \
    --http \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.addr=0.0.0.0 \
    --http.port=8545 \
    --http.api=web3,debug,eth,txpool,net,morph,engine \
    --networkid=2710 \
    --authrpc.addr="0.0.0.0" \
    --authrpc.port="56551" \
    --authrpc.vhosts="*" \
    --gcmode=archive \
    --authrpc.jwtsecret=/home/ritual/.morph/jwt-secret.txt \
    --log.filename=/home/ritual/.morph/geth.log \
    --miner.gasprice="100000000"
Restart=on-failure
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/morph_noded.service > /dev/null << EOF
[Unit]
Description=Morph Node Service
After=network.target
Wants=network.target

[Service]
User=ritual
Group=ritual
ExecStart=/home/ritual/.morph/morph/node/build/bin/morphnode --home /home/ritual/.morph/node-data \
--l2.jwt-secret /home/ritual/.morph/jwt-secret.txt \
--l2.eth http://127.0.0.1:8545 \
--l2.engine http://127.0.0.1:56551 \
--log.filename /home/ritual/.morph/node.log
Restart=on-failure
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart morph_gethd morph_noded

rm -rf /home/ritual/.morph/snapshot-20240805-1 /home/ritual/.morph/snapshot-20240805-1.tar.gz

sleep 8

systemctl status morph_gethd morph_noded
