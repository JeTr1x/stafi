#!/bin/bash

# Вписываем параметры в переменные:
read -rp "Enter PRIVKEY: " PRIVKEY
read -rp "Enter RPC_KEY: " RPC_KEY
read -rp "Enter SLP_MINS: " SLPM
NODEKEY=$(openssl rand -hex 32)
PASSPHRASE="9XYl2Vvr72obuN4A0YEn"
echo ""
echo "================================================================"
echo "YOUR NODEKEY:" $NODEKEY
echo "================================================================"
echo ""

# Клонируем проект:
git clone https://github.com/waku-org/nwaku-compose
cd nwaku-compose

# Создаем .env файл из примера .env.example:
cp .env.example .env

# Вставляем переменные в.env:
sed -i "s|RLN_RELAY_ETH_CLIENT_ADDRESS=https://sepolia.infura.io/v3/<key>|RLN_RELAY_ETH_CLIENT_ADDRESS=https://sepolia.infura.io/v3/$RPC_KEY|g" .env
sed -i "s|ETH_TESTNET_KEY=<YOUR_TESTNET_PRIVATE_KEY_HERE>|ETH_TESTNET_KEY=$PRIVKEY|g" .env
sed -i "s|RLN_RELAY_CRED_PASSWORD=\"my_secure_keystore_password\"|RLN_RELAY_CRED_PASSWORD=\"$PASSPHRASE\"|g" .env
sed -i "s|NODEKEY=|NODEKEY=$NODEKEY|g" .env

sed -ie "s|${NWAKU_IMAGE:-harbor.status.im/wakuorg/nwaku:v0.31.0}|wakuorg/nwaku:v0.32.0|" docker-compose.yml


# Меняем маппинг портов в docker-compose.yml:
sed -i "s|- 0.0.0.0:3000:3000|- 0.0.0.0:3222:3000|g" docker-compose.yml
sed -i "s|- 127.0.0.1:4000:4000|- 127.0.0.1:4222:4000|g" docker-compose.yml
sed -i "s|8000:8000|8222:8000|g" docker-compose.yml
sed -i "s|- 80:80 #Let's Encrypt|- 82:80 #Let's Encrypt|g" docker-compose.yml
echo "Environment configuration completed!"
((SLPT=$SLPM*60))
echo "Sleeping" $SLPT "seconds"
sleep $SLPT

# Регистрируем RLN в сети Sepolia:
# Может не сразу регаться из-за дорогого газа
./register_rln.sh

# Запускаем контейнеры:
docker compose down && docker compose up -d
docker compose logs -f nwaku

# Для бэкапа сохраняем keystore из директории nwaku
