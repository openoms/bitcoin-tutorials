# Download and run this script on the RaspiBlitz:
# $ wget https://github.com/openoms/bitcoin-tutorials/raw/master/electrs/electrs_to_RaspiBlitz.sh && bash electrs_to_RaspiBlitz.sh

# https://github.com/romanz/electrs/blob/master/doc/usage.md

#cleanup
sudo systemctl stop electrs
sudo systemctl disable electrs
sudo rm -f /etc/systemd/system/electrs.service
sudo rm -f /home/electrs/.electrs/config.toml 

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
# workaround to keep Rust at v1.37.0
# check with: $ /home/electrs/.rustup/toolchains/stable-armv7-unknown-linux-gnueabihf/bin/rustc --version
sudo -u electrs /home/electrs/.cargo/bin/rustup install 1.37.0
sudo -u electrs /home/electrs/.cargo/bin/rustup override set 1.37.0

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
sudo mkdir /mnt/hdd/electrs 2>/dev/null
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
echo "installing Nginx"
echo "***"
echo ""

sudo apt-get install -y nginx
sudo /etc/init.d/nginx start

echo ""
echo "***"
echo "Create a self signed SSL certificate"
echo "***"
echo ""

#https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes
#https://stackoverflow.com/questions/8075274/is-it-possible-making-openssl-skipping-the-country-common-name-prompts

echo "
[req]
prompt             = no
default_bits       = 2048
default_keyfile    = localhost.key
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = v3_ca

[req_distinguished_name]
C = US
ST = California
L = Los Angeles
O = Our Company Llc
#OU = Org Unit Name
CN = Our Company Llc
#emailAddress = info@example.com

[req_ext]
subjectAltName = @alt_names

[v3_ca]
subjectAltName = @alt_names

[alt_names]
DNS.1   = localhost
DNS.2   = 127.0.0.1
" | sudo tee /mnt/hdd/electrs/localhost.conf

cd /mnt/hdd/electrs
sudo openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config localhost.conf

sudo cp localhost.crt /etc/ssl/certs/localhost.crt
sudo cp localhost.key /etc/ssl/private/localhost.key

echo ""
echo "***"
echo "Setting up nginx.conf"
echo "***"
echo ""

isElectrs=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'upstream electrs')
if [ ${isElectrs} -gt 0 ]; then
        echo "electrs is already configured with Nginx. To edit manually run \`sudo nano /etc/nginx/nginx.conf\`"

elif [ ${isElectrs} -eq 0 ]; then

        isStream=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'stream {')
        if [ ${isStream} -eq 0 ]; then

        echo "
stream {
        upstream electrs {
                server 127.0.0.1:50001;
        }
        server {
                listen 50002 ssl;
                proxy_pass electrs;
                ssl_certificate /etc/ssl/certs/localhost.crt;
                ssl_certificate_key /etc/ssl/private/localhost.key;
                ssl_session_cache shared:SSL-electrs:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

        elif [ ${isStream} -eq 1 ]; then
                sudo truncate -s-2 /etc/nginx/nginx.conf
                echo "

        upstream electrs {
                server 127.0.0.1:50001;
        }
        server {
                listen 50002 ssl;
                proxy_pass electrs;
                ssl_certificate /etc/ssl/certs/localhost.crt;
                ssl_certificate_key /etc/ssl/private/localhost.key;
                ssl_session_cache shared:SSL-electrs:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

        elif [ ${isStream} -gt 1 ]; then

                echo " Too many \`stream\` commands in nginx.conf. Please edit manually: \`sudo nano /etc/nginx/nginx.conf\` and retry"
                exit 1
        fi
fi

echo "allow port 50002 on ufw"
sudo ufw allow 50002

sudo systemctl enable nginx
sudo systemctl restart nginx

echo ""
echo "***"
echo "Installing the systemd service"
echo "***"
echo ""

# sudo nano /etc/systemd/system/electrs.service 
echo "
[Unit]
Description=Electrs
After=bitcoind.service

[Service]
WorkingDirectory=/home/electrs/electrs
ExecStart=/home/electrs/electrs/target/release/electrs --index-batch-size=10 --electrum-rpc-addr=\"0.0.0.0:50001\"
User=electrs
Group=electrs
Type=simple
KillMode=process
TimeoutSec=60
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
" | sudo tee -a /etc/systemd/system/electrs.service 

sudo systemctl enable electrs
sudo systemctl start electrs
# manual start:
# sudo -u electrs /home/electrs/.cargo/bin/cargo run --release -- --index-batch-size=10 --electrum-rpc-addr="0.0.0.0:50001"
echo ""
echo "***"
echo "Starting electrs in the background"
echo "***"
echo ""

# Hidden Service for electrs if Tor active
source /mnt/hdd/raspiblitz.conf
if [ "${runBehindTor}" = "on" ]; then
    isElectrsTor=$(sudo cat /etc/tor/torrc 2>/dev/null | grep -c 'electrs')
    if [ ${isElectrsTor} -eq 0 ]; then
        echo "
        # Hidden Service for Electrum Server
        HiddenServiceDir /mnt/hdd/tor/electrs
        HiddenServiceVersion 3
        HiddenServicePort 50001 127.0.0.1:50001
        " | sudo tee -a /etc/tor/torrc

        sudo systemctl restart tor
        sudo systemctl restart tor@default
    fi
    TOR_ADDRESS=$(sudo cat /mnt/hdd/tor/electrs/hostname)
    echo ""
    echo "***"
    echo "The Tor Hidden Service address for electrs is:"
    echo "$TOR_ADDRESS"
    echo "***"
    echo "" 
fi

echo ""
echo "To connect from outside of the local network make sure the port 50002 is forwarded on the router"
echo "Electrum wallet: start with the options \`electrum --oneserver --server RaspiBlitz_IP:50002:s\`"
echo ""