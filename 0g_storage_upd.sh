
read -p "Enter wallet private key: " ZG_PK

systemctl stop zgstorage
rm -rf 0g-storage-node
git clone -b v0.3.2 https://github.com/0glabs/0g-storage-node.git

cd $HOME/0g-storage-node
mkdir -p $HOME/0g-storage-node/target/release/
wget http://157.90.128.250:1313/zgs_node
chmod +x zgs_node
mv zgs_node $HOME/0g-storage-node/target/release/

ENR_ADDRESS=$(wget -qO- eth0.me)

ENR_ADDRESS=${ENR_ADDRESS}
LOG_CONTRACT_ADDRESS="0x8873cc79c5b3b5666535C825205C9a128B1D75F1"
MINE_CONTRACT="0x85F6722319538A805ED5733c5F4882d96F1C7384"
ZGS_LOG_SYNC_BLOCK="802"
BLOCKCHAIN_RPC_ENDPOINT="http://127.0.0.1:22345"


sed -i 's|^miner_key = ""|miner_key = "'"$ZG_PK"'"|' $HOME/0g-storage-node/run/config.toml

sed -i '
s|^miner_key = ""|miner_key = "'"$ZG_PK"'"|
s|^\s*#\?\s*network_dir\s*=.*|network_dir = "network"|
s|^\s*#\?\s*network_enr_address\s*=.*|network_enr_address = "'"$ENR_ADDRESS"'"|
s|^\s*#\?\s*network_enr_tcp_port\s*=.*|network_enr_tcp_port = 1234|
s|^\s*#\?\s*network_enr_udp_port\s*=.*|network_enr_udp_port = 1234|
s|^\s*#\s*watch_loop_wait_time_ms\s*=.*|watch_loop_wait_time_ms = 1000|
s|^\s*#\?\s*network_libp2p_port\s*=.*|network_libp2p_port = 1234|
s|^\s*#\?\s*network_discovery_port\s*=.*|network_discovery_port = 1234|
s|^\s*#\s*rpc_listen_address_admin\s*=.*|rpc_listen_address_admin = "0.0.0.0:5679"|
s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#\?\s*db_dir\s*=.*|db_dir = "db"|
s|^\s*#\?\s*log_config_file\s*=.*|log_config_file = "log_config"|
s|^\s*#\?\s*log_directory\s*=.*|log_directory = "log"|
s|^\s*#\?\s*network_boot_nodes\s*=.*|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAkzRjxK2gorngB1Xq84qDrT4hSVznYDHj6BkbaE4SGx9oS"\]|
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
s|^\s*#\?\s*mine_contract_address\s*=.*|mine_contract_address = "'"$MINE_CONTRACT"'"|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
' $HOME/0g-storage-node/run/config.toml



sudo tee /etc/systemd/system/zgstorage.service > /dev/null <<EOF
[Unit]
Description=zgstorage Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/0g-storage-node/run
ExecStart=/root/0g-storage-node/target/release/zgs_node --config /root/0g-storage-node/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF



sudo systemctl daemon-reload && \
sudo systemctl enable zgstorage && \
sudo systemctl start zgstorage

