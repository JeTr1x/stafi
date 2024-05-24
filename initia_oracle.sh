

addrline=$(cat $HOME/.initia/config/app.toml | grep "grpc]" -A 8 | grep "address = ")
arrIN=(${addrline//:/ })
grpc_port=$(echo ${arrIN[3]//'"'})
echo "Detected Initia Node GRPC port: "$grpc_port
init_portindex=${grpc_port:0:2}
echo "Initia Node port index: "$init_portindex

cd $HOME && \
ver="v0.4.3" && \
git clone https://github.com/skip-mev/slinky.git && \
cd slinky && \
git checkout $ver && \
make build && \
mv build/slinky /usr/local/bin/

echo 'export NODE_GRPC_ENDPOINT="0.0.0.0:'${grpc_port}'"' >> ~/.bash_profile
echo 'export ORACLE_CONFIG_PATH="$HOME/slinky/config/core/oracle.json"' >> ~/.bash_profile
echo 'export ORACLE_GRPC_PORT="'${init_portindex}'880"' >> ~/.bash_profile
echo 'export ORACLE_METRICS_ENDPOINT="0.0.0.0:'${init_portindex}'802"' >> ~/.bash_profile
source $HOME/.bash_profile

sed -i "s|\"url\": \".*\"|\"url\": \"$NODE_GRPC_ENDPOINT\"|" $ORACLE_CONFIG_PATH
sed -i "s|\"prometheusServerAddress\": \".*\"|\"prometheusServerAddress\": \"$ORACLE_METRICS_ENDPOINT\"|" $ORACLE_CONFIG_PATH
sed -i "s|\"port\": \".*\"|\"port\": \"$ORACLE_GRPC_PORT\"|" $ORACLE_CONFIG_PATH
sudo tee /etc/systemd/system/initia-oracle.service > /dev/null <<EOF
[Unit]
Description=Initia Oracle
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which slinky) --oracle-config-path $ORACLE_CONFIG_PATH
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload && \
sudo systemctl enable initia-oracle && \
sudo systemctl restart initia-oracle && \
sleep 5
sudo journalctl -u initia-oracle -o cat -n 100 --no-pager

ORACLE_GRPC_ENDPOINT="0.0.0.0:${init_portindex}880"
ORACLE_CLIENT_TIMEOUT="500ms"
NODE_APP_CONFIG_PATH="$HOME/.initia/config/app.toml"

sed -i '/\[oracle\]/,/\[/{s/^enabled *=.*/enabled = "true"/}' $NODE_APP_CONFIG_PATH
sed -i "/oracle_address =/c\oracle_address = \"$ORACLE_GRPC_ENDPOINT\"" $NODE_APP_CONFIG_PATH
sed -i "/client_timeout =/c\client_timeout = \"$ORACLE_CLIENT_TIMEOUT\"" $NODE_APP_CONFIG_PATH
sed -i '/metrics_enabled =/c\metrics_enabled = "false"' $NODE_APP_CONFIG_PATH
sudo systemctl restart initia && sudo journalctl -u initia -fn 10 -o cat







