# Fulcrum on a RaspiBlitz

This is a rough overview, the guide is a work in progress.

Tested environments:
  * Raspberry Pi4 8GB 64bit RaspberryOS with SSD and ZRAM  
   	First sync took 48h. Can expect 2 - 2.5 days.

  * Raspberry Pi4 4GB 64bit RaspberryOS with SSD and 10GB ZRAM  
    First sync took 3 days.
  	
  * See Pi-specific settings under heading "Create a config file".
  
Issue: <https://github.com/rootzoll/raspiblitz/issues/2924>

## FAQ
* Do I need to stop Electrs?

  Don't really need to, Electrs (and also Fulcrum) are very light once synched.
  Chugging through the 450GB transaction history poses the challenge for the RPi.
  Best is to stop all services you don't use, but testing is valuable in any circumstance.
  
## Prepare bitcoind
* To avoid errors like
```
503 (content): Work queue depth exceeded
``` 
set in the `/mnt/hdd/bitcoin/bitcoin.conf`:
```
txindex=1
whitelist=download@127.0.0.1
rpcworkqueue=512
rpcthreads=128
zmqpubhashblock=tcp://0.0.0.0:8433
```

* Restart bitcoind
```
sudo systemctl bitcoind restart
```
* If the txindex was not built before WAIT until it finishes (monitor the bitcoin `debug.log`).
```
sudo tail -n 100 -f /mnt/hdd/bitcoin/debug.log | grep txindex
```

## Prepare the system and directories

```
# Create a dedicated user
sudo adduser --disabled-password --gecos "" fulcrum
cd /home/fulcrum

# sudo -u fulcrum git clone https://github.com/cculianu/Fulcrum
# cd fulcrum

# Install dependencies
# sudo apt install -y libzmq3-dev
sudo apt install -y libssl-dev # was needed on Debian Bullseye

# Set the platform
if [ $(uname -m) = "aarch64" ]; then
  build="arm64-linux"
elif [ $(uname -m) = "x86_64" ]; then
  build="x86_64-linux-ub16"
fi

# Download the prebuilt binary
sudo -u fulcrum wget https://github.com/cculianu/Fulcrum/releases/download/v1.6.0/Fulcrum-1.6.0-${build}.tar.gz
sudo -u fulcrum  wget https://github.com/cculianu/Fulcrum/releases/download/v1.6.0/Fulcrum-1.6.0-${build}.tar.gz.asc
sudo -u fulcrum  wget https://github.com/cculianu/Fulcrum/releases/download/v1.6.0/Fulcrum-1.6.0-${build}.tar.gz.sha256sum

# Verify
# Get the PGP key
curl https://raw.githubusercontent.com/Electron-Cash/keys-n-hashes/master/pubkeys/calinkey.txt | sudo -u fulcrum gpg --import

# Look for 'Good signature'
sudo -u fulcrum  gpg --verify Fulcrum-1.6.0-${build}.tar.gz.asc

# Look for 'OK'
sudo -u fulcrum sha256sum -c Fulcrum-1.6.0-${build}.tar.gz.sha256sum

# Decompress
sudo -u fulcrum tar -xvf Fulcrum-1.6.0-${build}.tar.gz

# Create the database directory in /mnt/hdd/app-storage (on the disk)
sudo mkdir -p /mnt/hdd/app-storage/fulcrum/db
sudo chown -R fulcrum:fulcrum /mnt/hdd/app-storage/fulcrum

# Create a symlink to /home/fulcrum/.fulcrum
sudo ln -s /mnt/hdd/app-storage/fulcrum /home/fulcrum/.fulcrum
sudo chown -R fulcrum:fulcrum /home/fulcrum/.fulcrum

```

## Create a config file  
* <https://github.com/cculianu/Fulcrum/blob/master/doc/fulcrum-example-config.conf>
* Can paste the this as a block to create the config file, but fill in the PASSWORD_B (Bitcoin Core RPC password):
```
PASSWORD_B="your-password-here"
```
```
echo "\
datadir = /home/fulcrum/.fulcrum/db
bitcoind = 127.0.0.1:8332
rpcuser = raspibolt
rpcpassword = ${PASSWORD_B}

# RPi optimizations
# Avoid 'bitcoind request timed out'
bitcoind_timeout = 300

# Reduce load
bitcoind_clients = 1
worker_threads = 2
db_mem=1024

# Settings tested with 4GB RAM + ZRAM
db_max_open_files=500
fast-sync = 512

# Settings testetd with 8GB RAM + ZRAM
#db_max_open_files=500
#fast-sync = 2048

# Server connections
# Disable peer discovery and public server options
peering = false
announce = false
tcp = 0.0.0.0:50021
#cert = /path/to/server-cert.pem
#key = /path/to/server-key.pem
#ssl = 0.0.0.0:50022
" | sudo -u fulcrum tee /home/fulcrum/.fulcrum/fulcrum.conf
```
* The ports 50021 and 50022 are used to not interfere with a possible Electrs or ElectrumX instance.
* Note the different settings for 4 and 8 GB RAM
* Edit afterwards with `sudo nano /home/fulcrum/.fulcrum/fulcrum.conf`

## Create a systemd service  
* Can paste this as a block to create the fulcrum.service file:
```
echo "\
[Unit]
Description=Fulcrum
After=network.target bitcoind.service

[Service]
ExecStart=/home/fulcrum/Fulcrum-1.6.0-${build}/Fulcrum /home/fulcrum/.fulcrum/fulcrum.conf
User=fulcrum
LimitNOFILE=8192
TimeoutStopSec=30min
Restart=on-failure

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/fulcrum.service
```

## Start
* Depending on the available RAM it is a good idea to keep at least 10GB swap:  
  <https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-debian-10>
  can consider ZRAM: 
  <https://haydenjames.io/raspberry-pi-performance-add-zram-kernel-parameters/>
  <https://github.com/rootzoll/raspiblitz/issues/2905>
```
sudo systemctl enable fulcrum
sudo systemctl start fulcrum
```

## Monitor
```
sudo journalctl -fu fulcrum
sudo systemctl status fulcrum
```

## Open the firewall
```
sudo ufw allow 50021 comment 'Fulcrum TCP'
sudo ufw allow 50022 comment 'Fulcrum SSL'
```    

## Set up SSL
* Paste this code as a block to make Fulcrum available on the port 50022 with SSL ncryption through Nginx
```
cd /home/fulcrum/.fulcrum

# Create a self signed SSL certificate
sudo -u fulcrum openssl genrsa -out selfsigned.key 2048

echo "\
[req]
prompt             = no
default_bits       = 2048
default_keyfile    = selfsigned.key
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = v3_ca

[req_distinguished_name]
C = US
ST = Texas
L = Fulcrum
O = RaspiBlitz
CN = RaspiBlitz

[req_ext]
subjectAltName = @alt_names

[v3_ca]
subjectAltName = @alt_names

[alt_names]
DNS.1   = localhost
DNS.2   = 127.0.0.1
" | sudo -u fulcrum tee localhost.conf

sudo -u fulcrum openssl req -new -x509 -sha256 -key selfsigned.key \
    -out selfsigned.cert -days 3650 -config localhost.conf


# Setting up the nginx.conf
    isConfigured=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'upstream fulcrum')
    if [ ${isConfigured} -gt 0 ]; then
            echo "fulcrum is already configured with Nginx. To edit manually run \`sudo nano /etc/nginx/nginx.conf\`"

    elif [ ${isConfigured} -eq 0 ]; then

            isStream=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'stream {')
            if [ ${isStream} -eq 0 ]; then

            echo "
stream {
        upstream fulcrum {
                server 127.0.0.1:50021;
        }
        server {
                listen 50022 ssl;
                proxy_pass fulcrum;
                ssl_certificate /home/fulcrum/.fulcrum/selfsigned.cert;
                ssl_certificate_key /home/fulcrum/.fulcrum/selfsigned.key;
                ssl_session_cache shared:SSL-fulcrum:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

            elif [ ${isStream} -eq 1 ]; then
                    sudo truncate -s-2 /etc/nginx/nginx.conf
                    echo "
        upstream fulcrum {
                server 127.0.0.1:50021;
        }
        server {
                listen 50022 ssl;
                proxy_pass fulcrum;
                ssl_certificate /home/fulcrum/.fulcrum/selfsigned.cert;
                ssl_certificate_key /home/fulcrum/.fulcrum/selfsigned.key;
                ssl_session_cache shared:SSL-fulcrum:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

            elif [ ${isStream} -gt 1 ]; then
                    echo " Too many \`stream\` commands in nginx.conf. Please edit manually: \`sudo nano /etc/nginx/nginx.conf\` and retry"
                    exit 1
            fi
    fi

# Test nginx
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

## Create a Tor .onion service
* On RaspiBlitz v1.7.2 run:
  ```
  /home/admin/config.scripts/tor.onion-service.sh fulcrum 50021 50021 50022 50022
  ```
* Previous versions:
  ```
  /home/admin/config.scripts/network.hiddenservice.sh fulcrum 50021 50021 50022 50022
  ```
* To set up manually see the guide [here](tor_hidden_service_example.md).
  
  
## Remove the Fulcrum user and installation (not the database)
```
sudo systemctl disable fulcrum
sudo systemctl stop fulcrum
sudo userdel -rf fulcrum

# Remove Tor service
/home/admin/config.scripts/tor.onion-service.sh off electrs

# Close ports on firewall
sudo ufw deny 50021
sudo ufw deny 50022

# To remove the database directory
# sudo rm -rf /mnt/hdd/app-storage/fulcrum
```

## Sources:
* <https://github.com/cculianu/Fulcrum>
* <https://sparrowwallet.com/docs/server-performance.html>
