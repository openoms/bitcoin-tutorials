## Install BTCPayServer on the RaspiBlitz

### Installation

Log in to your RaspiBlitz as `admin` and work in the terminal:

* Install Dot-Net for ARM
    ```bash
    cd /home/admin
    sudo apt-get -y install libunwind8 gettext libssl1.0
    wget https://download.visualstudio.microsoft.com/download/pr/9650e3a6-0399-4330-a363-1add761127f9/14d80726c16d0e3d36db2ee5c11928e4/dotnet-sdk-2.2.102-linux-arm.tar.gz
    wget https://download.visualstudio.microsoft.com/download/pr/9d049226-1f28-4d3d-a4ff-314e56b223c5/f67ab05a3d70b2bff46ff25e2b3acd2a/aspnetcore-runtime-2.2.1-linux-arm.tar.gz
    sudo mkdir /opt/dotnet
    sudo tar -xvf dotnet-sdk-2.2.102-linux-arm.tar.gz -C /opt/dotnet/
    sudo tar -xvf aspnetcore-runtime-2.2.1-linux-arm.tar.gz -C /opt/dotnet/
    sudo ln -s /opt/dotnet/dotnet /usr/local/bin
    dotnet --info
    ```
* Install Nginx & Certbot  
`sudo apt-get install nginx-full certbot -y`

* Install NBXplorer
    ```bash
    cd /home/admin
    git clone https://github.com/dgarage/NBXplorer.git
    cd NBXplorer
    ./build.sh
    ```

* Create the NBXplorer system unit file  
`sudo nano /etc/systemd/system/nbxplorer.service`

    * Copy and paste the following code:
    ```
    ## Start of nbxplorer service file ##
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
    ## end of nbxplorer service file ##
    ```

* reload the systemd daemon  
`sudo systemctl daemon-reload`

* enable nbxplorer service  
`sudo systemctl enable nbxplorer`

* start nbxplorer service  
`sudo systemctl start nbxplorer`

* check to see if nbxplorer is running  
`sudo systemctl status nbxplorer`

* add your Raspiblitz RPC credentials to the nbxplorer configuration settings  
`nano /home/admin/.nbxplorer/Main/settings.config`

* Locate the "* By user name and password" section and uncomment these two lines and change the username and password.   
The username is raspibolt and the password is what you set while installing raspiblitz
    ```
    btc.rpc.user=raspibolt
    btc.rpc.password=yourVerySecretPassword
    ```

* restart nbxplorer  
`sudo systemctl restart nbxplorer`

* Install BTCPayServer
    ```bash
    cd /home/admin
    git clone https://github.com/btcpayserver/btcpayserver.git
    cd btcpayserver
    ./build.sh
    ```

* create the BTCPayServer system unit file  
`sudo nano /etc/systemd/system/btcpayserver.service`

* copy and paste the following code:
    ```
    ## Start of btcpayserver service file ##
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
    ## End of BTCPayServer service file ##
    ```

* reload the systemd daemon  
`sudo systemctl daemon-reload`

* enable btcpayserver service    
`sudo systemctl enable btcpayserver`

* start btcpayserver  
`sudo systemctl start btcpayserver`

* check to see if btcpayserver is running  
`sudo systemctl status btcpayserver`

* update your btcpayserver settings  
`nano /home/admin/.btcpayserver/Main/settings.config`

* make sure the following items are uncommented and correct. Replace `example.com` with your domain name
    ```
    ### Global settings ###
    network=mainnet

    ### Server settings ###
    port=23000
    bind=127.0.0.1
    externalurl=https://btcpay.example.com

    ### NBXplorer settings ###
    BTC.explorer.url=http://127.0.0.1:24444/
    BTC.lightning=type=lnd-rest;server=https://127.0.0.1:8080/;macaroonfilepath=/home/admin/.lnd/data/chain/bitcoin/mainnet/admin.macaroon;certthumbprint=<paste your thumbprint here>
    ```
* save the file we will get the cert thumbprint next
* get your cert thumbprint for BTCPayServer Lightning configuration  
`cd /home/admin`  
`openssl x509 -noout -fingerprint -sha256 -inform pem -in ~/.lnd/tls.cert`

* copy thumbprint output to clipboard
* replace thumbprint for lightning configuration  
`sudo nano /home/admin/.btcpayserver/Main/settings.config`

* paste thumbprint at the end of this line  
`BTC.lightning=type=lnd-rest;server=https://127.0.0.1:8080/;macaroonfilepath=/home/admin/.lnd/data/chain/bitcoin/mainnet/admin.macaroon;certthumbprint=<paste your thumbprint here>`

* restart btcpayserver   
`sudo systemctl restart btcpayserver`

* Open Port 80, 443 on the router
    ```bash
    sudo ufw allow 80
    sudo ufw allow 443
    ```
* Get your SSL certification using certbot. Change `btcpay.example.com `  
`sudo certbot certonly --authenticator standalone -d btcpay.example.com --pre-hook "service nginx stop" --post-hook "service nginx start"`

* add reverse proxy for btcpayserver

* remove default nginx configuration  
`sudo rm /etc/nginx/sites-enabled/default`

* create the btcpayserver configuration   
`sudo nano /etc/nginx/sites-available/btcpayserver`

* Paste the following, make sure you change the domain name to yours. Change all 4x `btcpay.example.com`
```
## start of Nginx config

# If we receive X-Forwarded-Proto, pass it through; otherwise, pass along the
# scheme used to connect to this server
map $http_x_forwarded_proto $proxy_x_forwarded_proto {
  default $http_x_forwarded_proto;
  ''      $scheme;
}
# If we receive X-Forwarded-Port, pass it through; otherwise, pass along the
# server port the client connected to
map $http_x_forwarded_port $proxy_x_forwarded_port {
  default $http_x_forwarded_port;
  ''      $server_port;
}
# If we receive Upgrade, set Connection to "upgrade"; otherwise, delete any
# Connection header that may have been passed to this server
map $http_upgrade $proxy_connection {
  default upgrade;
  '' close;
}
# Apply fix for very long server names
#server_names_hash_bucket_size 128;
# Prevent Nginx Information Disclosure
server_tokens off;
# Default dhparam
# Set appropriate X-Forwarded-Ssl header
map $scheme $proxy_x_forwarded_ssl {
  default off;
  https on;
}

gzip_types text/plain text/css application/javascript application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
log_format vhost '$host $remote_addr - $remote_user [$time_local] '
                 '"$request" $status $body_bytes_sent '
                 '"$http_referer" "$http_user_agent"';
access_log off;
# HTTP 1.1 support
proxy_http_version 1.1;
proxy_buffering off;
proxy_set_header Host $http_host;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $proxy_connection;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
proxy_set_header X-Forwarded-Ssl $proxy_x_forwarded_ssl;
proxy_set_header X-Forwarded-Port $proxy_x_forwarded_port;
# Mitigate httpoxy attack (see README for details)
proxy_set_header Proxy "";

server {
    listen 80 default_server;
    server_name _;
    return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;
  server_name btcpay.example.com;
  ssl on;

  ssl_certificate /etc/letsencrypt/live/btcpay.example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/btcpay.example.com/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate /etc/letsencrypt/live/btcpay.example.com/chain.pem;

  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://localhost:23000;
  }
}

## end of Nginx config
```

* add symlink for btcpayserver site  
`sudo ln -s /etc/nginx/sites-available/btcpayserver /etc/nginx/sites-enabled/`

* restart nginx  
`sudo systemctl restart nginx`

### Continue with [Setting up BTCPayServer](/BTCPayServer/README.md#Setting-up-BTCPayServer)