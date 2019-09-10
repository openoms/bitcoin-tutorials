## Install BTCPayServer on the RaspiBlitz
#Heavily based on: https://gist.github.com/normandmickey/3f10fc077d15345fb469034e3697d0d0 

# to download and run: 
# wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/BTCPayServer/btcpay_to_blitz.sh && bash btcpay_to_blitz.sh

# requirements

echo ""
echo "***"
echo "Please confirm that the port 80, 443 and 9735 are forwarded to the IP of the RaspiBlitz by pressing [ENTER]" 
read key

echo ""
echo "***"
echo "Please type the domain/ddns you want to use for BTCPayServer followed by [ENTER]"
read YOUR_DOMAIN

echo ""
echo "***"
echo "Type the PASSWORD B of your RaspiBlitz followed by [ENTER] for the nbxplorer:"
read PASSWORD_B

# cleanup possible residual files from previus installs

sudo rm /home/admin/.nbxplorer/Main/settings.config
sudo rm /etc/systemd/system/nbxplorer.service
sudo rm /etc/systemd/system/btcpayserver.service
sudo rm /home/admin/.btcpayserver/Main/settings.config
sudo rm /etc/nginx/sites-available/btcpayserver

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

sudo apt-get install nginx-full certbot -y

# NBxplorer

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
ExecStart=/usr/local/bin/dotnet "/home/admin/NBXplorer/NBXplorer/bin/Release/netcoreapp2.1/NBXplorer.dll" -c /home/admin/.nbxplorer/Main/settings.config
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
sudo systemctl enable nbxplorer
sudo systemctl start nbxplorer

echo "
    btc.rpc.user=raspibolt
    btc.rpc.password=$PASSWORD_B
" | sudo tee -a /home/admin/.nbxplorer/Main/settings.config

sudo systemctl restart nbxplorer

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
ExecStart=/usr/local/bin/dotnet run --no-launch-profile --no-build -c Release -p "/home/admin/btcpayserver/BTCPayServer/BTCPayServer.csproj" -- $@
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
externalurl=https://btcpay.example.com

### NBXplorer settings ###
BTC.explorer.url=http://127.0.0.1:24444/
BTC.lightning=type=lnd-rest;server=https://127.0.0.1:8080/;macaroonfilepath=/home/admin/.lnd/data/chain/bitcoin/mainnet/admin.macaroon;certthumbprint=$FINGERPRINT
" | sudo tee -a /home/admin/.btcpayserver/Main/settings.config

sudo systemctl restart btcpayserver

sudo ufw allow 80
sudo ufw allow 443

# get SSL cert
sudo certbot certonly --authenticator standalone -d $YOUR_DOMAIN --pre-hook "service nginx stop" --post-hook "service nginx start"

sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.backup

echo "
server {
    listen 80 default_server;
    server_name _;
    return 301 https://$host$request_uri;
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
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://localhost:23000;
  }
}
" | sudo tee -a /etc/nginx/sites-available/btcpayserver

sudo ln -s /etc/nginx/sites-available/btcpayserver /etc/nginx/sites-enabled/

sudo systemctl restart nginx