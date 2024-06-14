

read -p "Enter wallet private key: " ZG_PK

git clone -b v0.3.0 https://github.com/0glabs/0g-storage-node.git

cd $HOME/0g-storage-node
mkdir -p $HOME/0g-storage-node/target/release/
wget http://95.216.21.235:22321/zgs_node
chmod +x zgs_node
mv zgs_node $HOME/0g-storage-node/target/release/

ENR_ADDRESS=$(wget -qO- eth0.me)

ENR_ADDRESS=${ENR_ADDRESS}
LOG_CONTRACT_ADDRESS="0xb8F03061969da6Ad38f0a4a9f8a86bE71dA3c8E7"
MINE_CONTRACT="0x96D90AAcb2D5Ab5C69c1c351B0a0F105aae490bE"
ZGS_LOG_SYNC_BLOCK="334797"
BLOCKCHAIN_RPC_ENDPOINT="https://0gevmrpc.nodebrand.xyz"


sed -i 's|^miner_key = ""|miner_key = "'"$ZG_PK"'"|' $HOME/0g-storage-node/run/config.toml


sed -i '
s|^\s*#\?\s*network_dir\s*=.*|network_dir = "network"|
s|^\s*#\?\s*network_enr_address\s*=.*|network_enr_address = "'"$ENR_ADDRESS"'"|
s|^\s*#\?\s*network_enr_tcp_port\s*=.*|network_enr_tcp_port = 1234|
s|^\s*#\?\s*network_enr_udp_port\s*=.*|network_enr_udp_port = 1234|
s|^\s*#\?\s*network_libp2p_port\s*=.*|network_libp2p_port = 1234|
s|^\s*#\?\s*network_discovery_port\s*=.*|network_discovery_port = 1234|
s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#\?\s*db_dir\s*=.*|db_dir = "db"|
s|^\s*#\?\s*log_config_file\s*=.*|log_config_file = "log_config"|
s|^\s*#\?\s*log_directory\s*=.*|log_directory = "log"|
s|^\s*#\?\s*network_boot_nodes\s*=.*|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAkzRjxK2gorngB1Xq84qDrT4hSVznYDHj6BkbaE4SGx9oS"\]|
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
s|^\s*#\?\s*mine_contract_address\s*=.*|mine_contract_address = "'"$MINE_CONTRACT"'"|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
s|^\s*miner_id\s*=\s*""|# miner_id = ""|
' $HOME/0g-storage-node/run/config.toml


sudo tee /etc/systemd/system/zgstorage.service > /dev/null <<EOF
[Unit]
Description=zgstorage Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF



sudo systemctl daemon-reload && \
sudo systemctl enable zgstorage && \
sudo systemctl start zgstorage







