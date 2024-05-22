
sudo tee regdomain.sh >/dev/null <<EOF
read -p "Enter domain: " INITIA_DOMAIN
netstat -tulpn | grep 657
read -p "Enter portnum (10-64): " INITIA_DPORT
echo 'export INITIA_DPORT='$INITIA_DPORT >> $HOME/.bash_profile
sudo certbot certonly -d $INITIA_DOMAIN --register-unsafely-without-email
