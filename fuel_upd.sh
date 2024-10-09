


source /root/.bashrc
fuelup self update
fuelup update
fuelup default latest
sed -ie "s|https://sepolia.infura.io/v3/*.\{32\}|http://162.55.4.42:32545|" /etc/systemd/system/fueld.service;
sudo systemctl daemon-reload
sudo systemctl enable fueld
sudo systemctl start fueld
sleep 10
sudo systemctl status fueld.service
