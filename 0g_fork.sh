

rm -rf $HOME/0g-chain 
rm $HOME/go/bin/0gchaind
cd
git clone -b v0.2.3 https://github.com/0glabs/0g-chain.git
./0g-chain/networks/testnet/install.sh
source ~/.profile

$HOME/go/bin/0gchaind tendermint unsafe-reset-all --keep-addr-book

rm $HOME/.0gchain/config/genesis.json
wget -P $HOME/.0gchain/config https://github.com/0glabs/0g-chain/releases/download/v0.2.3/genesis.json
peers=265120a9bb170cf21198aabf88f7908c9944897c@54.241.167.190:26656,497f865d8a0f6c830e2b73009a01b3edefb22577@54.176.175.48:26656,ffc49903241a4e442465ec78b8f421c56b3ae3d4@54.193.250.204:26656,f37bc8623bfa4d8e519207b965a24a288f3213d8@18.166.164.232:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.0gchain/config/config.toml

echo 'Updated, Restart the node'
