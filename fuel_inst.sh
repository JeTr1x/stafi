
read -p "P2P_PK: " P2P_PRIVATE_KEY


wget https://install.fuel.network -O fuel-up.sh
bash fuel-up.sh --no-modify-path
echo "export PATH="$HOME/.fuelup/bin:$PATH"" >> /root/.bashrc
export PATH="${HOME}/.fuelup/bin:${PATH}"
source /root/.bashrc
source /root/.bashrc
fuelup self update
fuelup update
fuelup default latest

cd
git clone https://github.com/FuelLabs/chain-configuration

echo "=========================================================================================================="
echo "Your key:" $P2P_PRIVATE_KEY
echo "=========================================================================================================="


sudo tee /etc/systemd/system/fueld.service > /dev/null <<EOF
[Unit]
Description=fuel full node
After=network-online.target
[Service]
User=root
WorkingDirectory=/root
ExecStart=/root/.fuelup/bin/fuel-core run --service-name=fuel-sepolia-testnet-node --keypair $P2P_PRIVATE_KEY --relayer http://162.55.4.42:32545 --ip=0.0.0.0 --port=4500 --peering-port=36333 --db-path=~/.fuel-sepolia-testnet --snapshot /root/chain-configuration/ignition-test --utxo-validation --poa-instant false --enable-p2p --reserved-nodes /dns4/p2p-testnet.fuel.network/tcp/30333/p2p/16Uiu2HAmDxoChB7AheKNvCVpD4PHJwuDGn8rifMBEHmEynGHvHrf --sync-header-batch-size 100 --enable-relayer --relayer-v2-listening-contracts=0x01855B78C1f8868DE70e84507ec735983bf262dA --relayer-da-deploy-height=5827607 --relayer-log-page-size=500 --sync-block-stream-buffer-size 30
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl restart fueld
sleep 8
systemctl status  fueld
