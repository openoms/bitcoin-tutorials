# Download and run this script on the RaspiBlitz:
# $ wget https://github.com/openoms/bitcoin-tutorials/raw/master/electrs/electrs_install_on_RaspiBlitz.sh && bash electrs_install_on_RaspiBlitz.sh

# https://github.com/romanz/electrs/blob/master/doc/usage.md

echo ""
echo "***"
echo "Creating the electrs user"
echo "***"
echo ""
sudo adduser --disabled-password --gecos "" electrs
cd /home/electrs

echo ""
echo "***"
echo "Installing Rust"
echo "***"
echo ""
sudo -u electrs curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo -u electrs sh -s -- -y
#source $HOME/.cargo/env
sudo apt update
sudo apt install -y clang cmake  # for building 'rust-rocksdb'

echo ""
echo "***"
echo "Downloading and building electrs. This will take ~30 minutes" # ~22 min on an Odroid XU4
echo "***"
echo ""
sudo -u electrs git clone https://github.com/romanz/electrs
cd /home/electrs/electrs
sudo -u electrs /home/electrs/.cargo/bin/cargo build --release

echo ""
echo "***"
echo "The electrs database will be built in /mnt/hdd/electrs/db. Takes ~18 hours and ~50Gb diskspace"
echo "***"
echo ""
sudo -u electrs mkdir /mnt/hdd/electrs 2>/dev/null
sudo chown -R electrs:electrs /mnt/hdd/electrs

echo ""
echo "***"
echo "getting RPC credentials from the bitcoin.conf"
echo "***"
echo ""
#echo "Type the PASSWORD B of your RaspiBlitz followed by [ENTER] (needed for Electrs to access the bitcoind RPC):"
#read PASSWORD_B
RPC_USER=$(sudo cat /mnt/hdd/bitcoin/bitcoin.conf | grep rpcuser | cut -c 9-)
PASSWORD_B=$(sudo cat /mnt/hdd/bitcoin/bitcoin.conf | grep rpcpassword | cut -c 13-)
echo "Done"

echo ""
echo "***"
echo "generating electrs.toml setting file with the RPC passwords"
echo "***"
echo ""
# generate setting file: https://github.com/romanz/electrs/issues/170#issuecomment-530080134
# https://github.com/romanz/electrs/blob/master/doc/usage.md#configuration-files-and-environment-variables

sudo rm -f /home/electrs/.electrs/config.toml 
sudo -u electrs mkdir /home/electrs/.electrs 2>/dev/null

touch /home/admin/config.toml
chmod 600 /home/admin/config.toml || exit 1 
cat > /home/admin/config.toml <<EOF
verbose = 4
timestamp = true
jsonrpc_import = true
db_dir = "/mnt/hdd/electrs/db"
cookie = "$RPC_USER:$PASSWORD_B"
EOF
sudo mv /home/admin/config.toml /home/electrs/.electrs/config.toml
sudo chown electrs:electrs /home/electrs/.electrs/config.toml

echo ""
echo "***"
echo "Open port 50001 on UFW "
echo "***"
echo ""
sudo ufw allow 50001

echo ""
echo "***"
echo "Checking for config.toml"
echo "***"
echo ""
if [ ! -f "/home/electrs/.electrs/config.toml" ]
    then
        echo "Failed to create config.toml"
        exit 1
    else
        echo "OK"
fi

echo ""
echo "***"
echo "Start Electrs "
echo "***"
echo ""
sudo -u electrs /home/electrs/.cargo/bin/cargo run --release -- --index-batch-size=10 --electrum-rpc-addr="0.0.0.0:50001"

# to preserve settings:
# see https://github.com/romanz/electrs/blob/master/src/config.rs
# sudo nano $HOME/electrs/src/config.rs 
# change the lines:
# 73: from: .takes_value(true), to: .default_value("raspibolt:PASSWORD B"),
# 132: from .default_value("Welcome to electrs (Electrum Rust Server)!") to your custom message