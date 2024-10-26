
cd ~
mkdir cysic-verifier
curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/verifier_linux > ~/cysic-verifier/verifier
curl -L https://cysic-verifiers.oss-accelerate.aliyuncs.com/libzkp.so > ~/cysic-verifier/libzkp.so

read -rp "Cysic reward address: " EVM_CYSIC_ADDR

cat <<EOF > cysic-verifier/config.yaml
chain:
  endpoint: "testnet-node-1.prover.xyz:9090"
  chain_id: "cysicmint_9000-1"
  gas_coin: "cysic"
  gas_price: 10
claim_reward_address: "${EVM_CYSIC_ADDR}"

server:
  cysic_endpoint: "https://api-testnet.prover.xyz"
EOF



cd ~/cysic-verifier/
chmod +x ~/cysic-verifier/verifier
echo "LD_LIBRARY_PATH=.:~/miniconda3/lib:$LD_LIBRARY_PATH CHAIN_ID=534352 ./verifier" > ~/cysic-verifier/start.sh
chmod +x ~/cysic-verifier/start.sh

sudo tee /etc/systemd/system/cysic-verifierd.service > /dev/null <<EOF
[Unit]
Description=cysic-verifier
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=/root/cysic-verifier
ExecStart=bash /root/cysic-verifier/start.sh
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sysemctl daemon-reload
systemctl enable cysic-verifierd
systemctl start cysic-verifierd
journalctl -fu cysic-verifierd

