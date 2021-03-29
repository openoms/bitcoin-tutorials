#!/bin/bash

# On a raspiblitz:
## download
# wget -O bonus.btcpaysetdomain.sh https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/BTCPayServer/bonus.btcpaysetdomain.sh
## inspect
# cat bonus.btcpaysetdomain.sh
## run and follow the instructions on screen
# bash bonus.btcpaysetdomain.sh on

# To undo the conf changes use:
# bash bonus.btcpaysetdomain.sh revert

if [ $1 = on ];then
  echo "# Custom script to set up nginx and the SSL certificate for BTCPay Server"

  source /mnt/hdd/raspiblitz.conf
  # add default value to raspi config if needed
  if ! grep -Eq "^BTCPayDomain=" /mnt/hdd/raspiblitz.conf; then
    echo "BTCPayDomain=off" >> /mnt/hdd/raspiblitz.conf
  fi

  echo " # Setting up Nginx and Certbot"
  localip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
  echo
  echo "***"
  echo "Confirm that the ports 80 and 443 are forwarded to your RaspiBlitz" 
  echo
  echo "Example settings for your router:"
  echo "forward the port 443 to port 443 on ${localip}"
  echo "forward the port 80 to port 80 on ${localip}"
  echo
  echo "Press [ENTER] to continue or use [CTRL + C] to exit"
  echo
  read key
  
  echo
  echo "***"
  echo "Type your domain or dynamicDNS pointing to your public IP and press [ENTER] or use [CTRL + C] to exit"
  echo
  echo "Example:"
  echo "btcpay.example.com"
  read YOUR_DOMAIN

  echo
  echo "***"
  echo "Type an email address that will be used to message about the expiration of the SSL certificate and press [ENTER] or use [CTRL + C] to exit"
  echo
  echo "Example:"
  echo "name@email.com"
  read YOUR_EMAIL
  

  # install nginx and certbot
  sudo pip install cffi
  sudo apt update
  sudo apt-get install -y nginx-full certbot
  
  sudo ufw allow 80 comment 'HTTP web server'
  sudo ufw allow 443 comment 'btcpayserver SSL'
  
  # get SSL cert
  sudo systemctl stop certbot 2>/dev/null
  sudo certbot certonly -a standalone -m $YOUR_EMAIL --agree-tos \
  -d $YOUR_DOMAIN -n --pre-hook "service nginx stop" \
  --post-hook "service nginx start" || exit 1

  # set nginx

  echo "# Will move the default, blitzweb.conf, public.conf and btcpayserver nginx configs to /etc/nginx/backups"
  echo "Press [ENTER] to continue or use [CTRL + C] to exit"
  read key
  sudo mkdir -p /etc/nginx/backups/sites-enabled
  sudo mkdir -p /etc/nginx/backups/sites-available

  sudo mv /etc/nginx/sites-enabled/blitzweb.conf /etc/nginx/backups/sites-enabled/blitzweb.conf
  sudo mv /etc/nginx/sites-enabled/public.conf /etc/nginx/backups/sites-enabled/public.conf

  sudo mv /etc/nginx/sites-enabled/default /etc/nginx/backups/sites-enabled/default
  sudo mv /etc/nginx/sites-enabled/btcpayserver /etc/nginx/backups/sites-enabled/btcpayserver

  sudo mv /etc/nginx/sites-available/btcpayserver /etc/nginx/backups/sites-available/btcpayserver

  echo "# Remove the default btcpay_ssl symlink from /etc/nginx/sites-enabled"
  sudo rm -f /etc/nginx/sites-enabled/btcpay_ssl.conf
  
  # paste this to create the new /etc/nginx/sites-available/btcpayserver
  # make sure YOUR_DOMAIN is set ( 'YOUR_DOMAIN=example.com')

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
" | sudo tee /etc/nginx/sites-available/btcpayserver
  echo "# Symlink /etc/nginx/sites-available/btcpayserver /etc/nginx/sites-enabled/"
  sudo ln -s /etc/nginx/sites-available/btcpayserver /etc/nginx/sites-enabled/ 2>/dev/null
  
  # test 
  sudo nginx -t
  # restart
  sudo systemctl restart nginx
 
  echo "# Setting up certbot-auto renewal service"

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
    
  echo "# setting value in raspiblitz config"
  sudo sed -i "s/^BTCPayDomain=.*/BTCPayDomain=$YOUR_DOMAIN/g" /mnt/hdd/raspiblitz.conf

  echo "OK done" 
fi

if [ $1 = revert ];then
  echo "# Revert the nginx configs"
  sudo mv  /etc/nginx/backups/sites-enabled/blitzweb.conf /etc/nginx/sites-enabled/blitzweb.conf
  sudo mv  /etc/nginx/backups/sites-enabled/public.conf /etc/nginx/sites-enabled/public.conf

  sudo mv /etc/nginx/backups/sites-enabled/default /etc/nginx/sites-enabled/default
  sudo mv /etc/nginx/backups/sites-enabled/btcpayserver /etc/nginx/sites-enabled/btcpayserver 

  sudo mv /etc/nginx/backups/sites-available/btcpayserver /etc/nginx/sites-available/btcpayserver

  echo "# Remove the nginx symlink"
  sudo rm -f /etc/nginx/sites-enabled/btcpayserver

  echo "# Symlink /etc/nginx/sites-enabled/btcpay_ssl.conf to /etc/nginx/sites-enabled/"
  sudo ln -s /etc/nginx/sites-enabled/btcpay_ssl.conf /etc/nginx/sites-enabled/
  
  echo "# Done"
  
  # test 
  sudo nginx -t
  # reload
  sudo systemctl reload nginx
fi
