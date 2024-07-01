rm -rf $HOME/0g-chain 
rm $HOME/go/bin/0gchaind
cd
git clone -b v0.2.3 https://github.com/0glabs/0g-chain.git
./0g-chain/networks/testnet/install.sh
source ~/.profile

$HOME/go/bin/0gchaind tendermint unsafe-reset-all --keep-addr-book
$HOME/go/bin/0gchaind config chain-id zgtendermint_16600-2

rm $HOME/.0gchain/config/genesis.json
wget -P $HOME/.0gchain/config https://github.com/0glabs/0g-chain/releases/download/v0.2.3/genesis.json
peers=81987895a11f6689ada254c6b57932ab7ed909b6@54.241.167.190:26656,010fb4de28667725a4fef26cdc7f9452cc34b16d@54.176.175.48:26656,e9b4bc203197b62cc7e6a80a64742e752f4210d5@54.193.250.204:26656,68b9145889e7576b652ca68d985826abd46ad660@18.166.164.232:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.0gchain/config/config.toml

echo 'Updated, Restart the node'
