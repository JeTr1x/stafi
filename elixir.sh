
wget https://files.elixir.finance/validator.env

echo "Enter private key:"
read -r PK
echo "Enter Val address:"
read -r VADDR
echo "Enter Moniker:"
read -r MONIKER
sed -i.bak -e "s|^STRATEGY_EXECUTOR_IP_ADDRESS=.*|STRATEGY_EXECUTOR_IP_ADDRESS=$(curl -s 2ip.ru)|" \
           -e "s|^STRATEGY_EXECUTOR_DISPLAY_NAME=.*|STRATEGY_EXECUTOR_DISPLAY_NAME=${MONIKER}|" \
           -e "s|^STRATEGY_EXECUTOR_BENEFICIARY=.*|STRATEGY_EXECUTOR_BENEFICIARY=${VADDR}|" \
           -e "s|^SIGNER_PRIVATE_KEY=.*|SIGNER_PRIVATE_KEY=${PK}|" $HOME/validator.env


docker pull elixirprotocol/validator:testnet --platform linux/amd64

mkdir -p /root/.elixir
mv /root/validator.env /root/.elixir/validator.env

# Start Your Validator:
docker run -d \
  --env-file /root/.elixir/validator.env \
  --name elixir \
  -p 17690:17690 \
  --restart unless-stopped \
  elixirprotocol/validator:testnet

  rm elixir.sh

  docker logs -f elixir
