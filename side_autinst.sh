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

sleep 2
read -p "Enter node name: " SIDE_MONIK
echo 'export SIDE_MONIK='$SIDE_MONIK >> $HOME/.bash_profile

# Install dependencies for building from source
sudo apt update
sudo apt install -y curl git jq lz4 build-essential

# Install Go
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source .bash_profile

# Clone project repository
systemctl stop sided
cd && rm -rf sidechain
rm -rf .side/data
mv .side .side2-bak

git clone https://github.com/sideprotocol/sidechain.git
cd sidechain
git checkout v0.7.0-rc2

# Build binary
make install

# Set node CLI configuration
sided config chain-id side-testnet-3
sided config keyring-backend test
sided config node tcp://localhost:26357

# Initialize the node
sided init $SIDE_MONIK --chain-id side-testnet-3

# Download genesis and addrbook files
curl -Ls https://snapshots.indonode.net/side-t/genesis.json > $HOME/.side/config/genesis.json
curl -Ls https://snapshots.indonode.net/side-t/addrbook.json > $HOME/.side/config/addrbook.json

# Set seeds
sed -i -e 's|^seeds *=.*|seeds = "6decdc5565bf5232cdf5597a7784bfe828c32277@158.220.126.137:11656,e9ee4fb923d5aab89207df36ce660ff1b882fc72@136.243.33.177:21656,9c14080752bdfa33f4624f83cd155e2d3976e303@side-testnet-seed.itrocket.net:45656"|' $HOME/.side/config/config.toml

# Set minimum gas price
sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.005uside"|' $HOME/.side/config/app.toml

# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
  $HOME/.side/config/app.toml

# Change ports
sed -i -e "s%:1317%:26317%; s%:8080%:26380%; s%:9090%:26390%; s%:9091%:26391%; s%:8545%:26345%; s%:8546%:26346%; s%:6065%:26365%" $HOME/.side/config/app.toml
sed -i -e "s%:26658%:26358%; s%:26657%:26357%; s%:6060%:26360%; s%:26656%:26356%; s%:26660%:26361%" $HOME/.side/config/config.toml


# Create a service
sudo tee /etc/systemd/system/sided.service > /dev/null << EOF
[Unit]
Description=Side node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which sided) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable sided.service

# Start the service and check the logs
sudo systemctl start sided.service
sudo journalctl -u sided.service -f --no-hostname -o cat
