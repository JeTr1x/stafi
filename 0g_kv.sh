
systemctl stop zgs_kv
rm -rf 0g-storage-kv
git clone https://github.com/0glabs/0g-storage-kv.git

cd 0g-storage-kv
mkdir -p $HOME/0g-storage-kv/target/release/
http://157.90.128.250:1313/zgs_kv
chmod +x zgs_kv
mv zgs_kv $HOME/0g-storage-kv/target/release/
cp $HOME/0g-storage-kv/run/config_example.toml $HOME/0g-storage-kv/run/config.toml

LOG_CONTRACT_ADDRESS="0x8873cc79c5b3b5666535C825205C9a128B1D75F1"
ZGS_LOG_SYNC_BLOCK="802"
BLOCKCHAIN_RPC_ENDPOINT="http://157.90.128.250:22345"


sed -i '
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
' $HOME/0g-storage-kv/run/config.toml

sudo tee /etc/systemd/system/zgs_kv.service > /dev/null <<EOF
[Unit]
Description=zgs_kv Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/0g-storage-kv/run
ExecStart=/root/0g-storage-kv/target/release/zgs_kv --config /home/ritual/0g-storage-kv/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && \
sudo systemctl enable zgs_kv && \
sudo systemctl start zgs_kv && \
sudo journalctl -u zgs_kv -f -o cat
