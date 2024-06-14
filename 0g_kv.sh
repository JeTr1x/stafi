

git clone https://github.com/0glabs/0g-storage-kv.git

cd 0g-storage-kv
mkdir -p $HOME/0g-storage-kv/target/release/
wget http://95.216.21.235:22321/zgs_kv
chmod +x zgs_kv
mv zgs_kv $HOME/0g-storage-kv/target/release/
cp $HOME/0g-storage-kv/run/config_example.toml $HOME/0g-storage-kv/run/config.toml

LOG_CONTRACT_ADDRESS="0xb8F03061969da6Ad38f0a4a9f8a86bE71dA3c8E7"
ZGS_LOG_SYNC_BLOCK="334797"
BLOCKCHAIN_RPC_ENDPOINT="https://0gevmrpc.nodebrand.xyz"


sed -i '
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
' $HOME/0g-storage-kv/run/config.toml
