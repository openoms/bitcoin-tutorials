## Install BTCPayServer on the RaspiBlitz
#Heavily based on: https://gist.github.com/normandmickey/3f10fc077d15345fb469034e3697d0d0 

# to download and run: 
# wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/BTCPayServer/btcpay_to_blitz.sh && bash btcpay_to_blitz.sh

#file="/etc/nginx/nginx.conf"
#if [ -f "$file" ]
#then
#  echo "$file found."
#  echo "There is an existing Nginx configuration which might fail if the setup continues"
#  echo "Press CRTL+C to abort or any key to continue"
#  read key
#fi

#use `sudo apt purge nginx-common certbot` to clean configuration

echo ""
echo "***"
echo "Confirm that the port 80, 443 and 9735 are forwarded to the IP of the RaspiBlitz by pressing [ENTER]" 
read key

echo ""
echo "***"
echo "Type the domain/ddns you want to use for BTCPayServer and press [ENTER]"
read YOUR_DOMAIN

echo ""
echo "***"
echo "Type an email address that will be used to register the SSL certificate and press [ENTER]"
read YOUR_EMAIL

# install nginx
sudo apt-get install nginx-full certbot -y

# get SSL cert
sudo certbot certonly -a standalone -m $YOUR_EMAIL --agree-tos -d $YOUR_DOMAIN --pre-hook "service nginx stop" --post-hook "service nginx start"

echo ""
echo "***"
echo "Setting up certbot-auto renewal service"
echo "***"
echo ""

sudo rm -f /etc/systemd/system/certbot.timer
echo "
[Unit]
Description=Certbot-auto renewal service

[Timer]
OnBootSec=20min
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
" | sudo tee -a /etc/systemd/system/certbot.timer

sudo rm -f /etc/systemd/system/certbot.service
echo "
[Unit]
Description=Certbot-auto renewal service
After=bitcoind.service

[Service]
WorkingDirectory=/home/admin/
ExecStart=sudo certbot renew --pre-hook \"service nginx stop\" --post-hook \"service nginx start\"

User=admin
Group=admin
Type=simple
KillMode=process
TimeoutSec=60
Restart=always
RestartSec=60
" | sudo tee -a /etc/systemd/system/certbot.service

sudo systemctl enable certbot.timer

# cleanup possible residual files from previous installs

sudo rm -f /home/admin/.nbxplorer/Main/settings.config
sudo rm -f /etc/systemd/system/nbxplorer.service
sudo rm -f /etc/systemd/system/btcpayserver.service
sudo rm -f /home/admin/.btcpayserver/Main/settings.config
sudo rm -f /etc/nginx/sites-available/btcpayserver

#dotNET

cd /home/admin
wget https://download.visualstudio.microsoft.com/download/pr/9650e3a6-0399-4330-a363-1add761127f9/14d80726c16d0e3d36db2ee5c11928e4/dotnet-sdk-2.2.102-linux-arm.tar.gz
wget https://download.visualstudio.microsoft.com/download/pr/9d049226-1f28-4d3d-a4ff-314e56b223c5/f67ab05a3d70b2bff46ff25e2b3acd2a/aspnetcore-runtime-2.2.1-linux-arm.tar.gz
sudo mkdir /opt/dotnet
sudo apt-get -y install libunwind8 gettext libssl1.0
sudo tar -xvf dotnet-sdk-2.2.102-linux-arm.tar.gz -C /opt/dotnet/
sudo tar -xvf aspnetcore-runtime-2.2.1-linux-arm.tar.gz -C /opt/dotnet/
sudo ln -s /opt/dotnet/dotnet /usr/local/bin
dotnet --info

echo ""
echo "***"
echo "Installing NBXplorer"
echo "***"
echo ""

cd /home/admin
git clone https://github.com/dgarage/NBXplorer.git
cd NBXplorer
./build.sh

echo "
[Unit]
Description=NBXplorer daemon
Requires=bitcoind.service
After=bitcoind.service

[Service]
ExecStart=/usr/local/bin/dotnet \"/home/admin/NBXplorer/NBXplorer/bin/Release/netcoreapp2.1/NBXplorer.dll\" -c /home/admin/.nbxplorer/Main/settings.config
User=admin
Group=admin
Type=simple
PIDFile=/run/nbxplorer/nbxplorer.pid
Restart=on-failure

PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
PrivateDevices=true

[Install]
WantedBy=multi-user.target
" | sudo tee -a /etc/systemd/system/nbxplorer.service

sudo systemctl daemon-reload
# restart to create settings.config if was running already
sudo systemctl restart nbxplorer
sudo systemctl enable nbxplorer
sudo systemctl start nbxplorer


echo "Checking for nbxplorer config"
while [ ! -f "/home/admin/.nbxplorer/Main/settings.config" ]
    do
      echo "Waiting for nbxplorer to start - CTRL+C to abort"
      sleep 10
done

echo ""
echo "***"
echo "getting RPC credentials from the bitcoin.conf"
RPC_USER=$(sudo cat /mnt/hdd/bitcoin/bitcoin.conf | grep rpcuser | cut -c 9-)
PASSWORD_B=$(sudo cat /mnt/hdd/bitcoin/bitcoin.conf | grep rpcpassword | cut -c 13-)
chmod 600 /home/admin/.nbxplorer/Main/settings.config || exit 1
cat >> /home/admin/.nbxplorer/Main/settings.config <<EOF
btc.rpc.user=raspibolt
btc.rpc.password=$PASSWORD_B
EOF

sudo systemctl restart nbxplorer

echo ""
echo "***"
echo "Installing BTCPayServer"
echo "***"
echo ""

cd /home/admin
git clone https://github.com/btcpayserver/btcpayserver.git
cd btcpayserver
./build.sh

echo "
[Unit]
Description=BtcPayServer daemon
Requires=btcpayserver.service
After=nbxplorer.service

[Service]
ExecStart=/usr/local/bin/dotnet run --no-launch-profile --no-build -c Release -p \"/home/admin/btcpayserver/BTCPayServer/BTCPayServer.csproj\" -- \$@
User=admin
Group=admin
Type=simple
PIDFile=/run/btcpayserver/btcpayserver.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
" | sudo tee -a /etc/systemd/system/btcpayserver.service

sudo systemctl daemon-reload
sudo systemctl enable btcpayserver
sudo systemctl start btcpayserver

# set thumbprint
FINGERPRINT=$(openssl x509 -noout -fingerprint -sha256 -inform pem -in ~/.lnd/tls.cert | cut -c 20-)

echo "
### Global settings ###
network=mainnet

### Server settings ###
port=23000
bind=127.0.0.1
externalurl=https://$YOUR_DOMAIN

### NBXplorer settings ###
BTC.explorer.url=http://127.0.0.1:24444/
BTC.lightning=type=lnd-rest;server=https://127.0.0.1:8080/;macaroonfilepath=/home/admin/.lnd/data/chain/bitcoin/mainnet/admin.macaroon;certthumbprint=$FINGERPRINT
" | sudo tee -a /home/admin/.btcpayserver/Main/settings.config

sudo systemctl restart btcpayserver

sudo ufw allow 80
sudo ufw allow 443

# set nginx
sudo rm -f /etc/nginx/sites-enabled/default

echo "
# If we receive X-Forwarded-Proto, pass it through; otherwise, pass along the
# scheme used to connect to this server
map \$http_x_forwarded_proto \$proxy_x_forwarded_proto {
  default \$http_x_forwarded_proto;
  ''      \$scheme;
}
# If we receive X-Forwarded-Port, pass it through; otherwise, pass along the
# server port the client connected to
map \$http_x_forwarded_port \$proxy_x_forwarded_port {
  default \$http_x_forwarded_port;
  ''      \$server_port;
}
# If we receive Upgrade, set Connection to \"upgrade\"; otherwise, delete any
# Connection header that may have been passed to this server
map \$http_upgrade \$proxy_connection {
  default upgrade;
  '' close;
}
# Apply fix for very long server names
#server_names_hash_bucket_size 128;
# Prevent Nginx Information Disclosure
server_tokens off;
# Default dhparam
# Set appropriate X-Forwarded-Ssl header
map \$scheme \$proxy_x_forwarded_ssl {
  default off;
  https on;
}

gzip_types text/plain text/css application/javascript application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
log_format vhost '\$host \$remote_addr - \$remote_user [\$time_local] '
                 '\"\$request\" \$status \$body_bytes_sent '
                 '\"\$http_referer\" \"\$http_user_agent\"';
access_log off;
# HTTP 1.1 support
proxy_http_version 1.1;
proxy_buffering off;
proxy_set_header Host \$http_host;
proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection \$proxy_connection;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$proxy_x_forwarded_proto;
proxy_set_header X-Forwarded-Ssl \$proxy_x_forwarded_ssl;
proxy_set_header X-Forwarded-Port \$proxy_x_forwarded_port;
# Mitigate httpoxy attack (see README for details)
proxy_set_header Proxy \"\";


server {
    listen 80 default_server;
    server_name _;
    return 301 https://\$host\$request_uri;
}

server {
  listen 443 ssl;
  server_name $YOUR_DOMAIN;
  ssl on;

  ssl_certificate /etc/letsencrypt/live/$YOUR_DOMAIN/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$YOUR_DOMAIN/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate /etc/letsencrypt/live/$YOUR_DOMAIN/chain.pem;

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://localhost:23000;
  }
}
" | sudo tee -a /etc/nginx/sites-available/btcpayserver

sudo ln -s /etc/nginx/sites-available/btcpayserver /etc/nginx/sites-enabled/

sudo systemctl restart nginx

echo ""
echo "Visit your BTCpayServer instance on https://$YOUR_DOMAIN"