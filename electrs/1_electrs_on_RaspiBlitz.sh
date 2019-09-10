# Download and run this script on the RaspiBlitz:
# $ wget https://github.com/openoms/bitcoin-tutorials/raw/master/electrs/electrs_install_on_RaspiBlitz.sh && bash electrs_install_on_RaspiBlitz.sh

# https://github.com/romanz/electrs/blob/master/doc/usage.md

#echo "Type the PASSWORD B of your RaspiBlitz followed by [ENTER] (needed for Electrs to access the bitcoind RPC):"
#read PASSWORD_B
echo "getting RPC credentials from the bitcoin.conf"
RPC_USER=$(sudo cat /mnt/hdd/bitcoin/bitcoin.conf | grep rpcuser | cut -c 9-)
PASSWORD_B=$(sudo cat /mnt/hdd/bitcoin/bitcoin.conf | grep rpcpassword | cut -c 13-)

echo ""
echo "***"
echo "Installing Rust - press 1 and [ENTER] when prompted"
echo "***"
echo ""
curl https://sh.rustup.rs -sSf | sh

source $HOME/.cargo/env
sudo apt update
sudo apt install -y clang cmake  # for building 'rust-rocksdb'
 
echo ""
echo "***"
echo "Downloading and building electrs. This will take ~30 minutes" # ~22 min on an Odroid XU4
echo "***"
echo ""
git clone https://github.com/romanz/electrs
cd electrs
cargo build --release
 
echo ""
echo "***"
echo "The electrs database will be built in /mnt/hdd/electrs/db. Takes ~18 hours and ~50Gb diskspace"
echo "***"
echo ""


sudo mkdir /mnt/hdd/electrs
sudo chown -R admin:admin /mnt/hdd/electrs
sudo ufw allow 50001

# generate setting file: https://github.com/romanz/electrs/issues/170#issuecomment-530080134
mkdir /home/admin/.electrs/
sudo rm /home/admin/.electrs/config.toml
touch /home/admin/.electrs/config.toml
echo "generating electrs.toml setting file with the RPC passwords"
(
echo "
verbose = 4
timestamp = true
jsonrpc_import = true
db_dir = \"/mnt/hdd/electrs/db\"
cookie = \"$RPC_USER:$PASSWORD_B\"
" | tee -a /home/admin/.electrs/config.toml
) &> /dev/null

# Run electrs
cargo run --release -- --index-batch-size=10 --electrum-rpc-addr="0.0.0.0:50001"

# to preserve settings:
# see https://github.com/romanz/electrs/blob/master/src/config.rs
# sudo nano $HOME/electrs/src/config.rs 
# change the lines:
# 73: from: .takes_value(true), to: .default_value("raspibolt:PASSWORD B"),
# 132: from .default_value("Welcome to electrs (Electrum Rust Server)!") to your custom message