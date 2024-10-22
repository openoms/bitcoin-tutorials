#!/bin/bash

# WORK IN PROGRESS
# see https://gist.github.com/NicolasDorier/1a7fce6836ee55a7fa2c7f65417b88b5

# check for certbot and nginx
if dpkg -l | grep -qw "certbot"; then
  echo "# certbot is already installed"
else
  sudo apt install -y certbot
fi
if dpkg -l | grep -qw "nginx"; then
  echo "# nginx is already installed"
else
  sudo apt install -y nginx
fi

echo "
Input your email:
"
read EMAIL

echo "
Input a subdomain set up with an A record pointing to this server:
eg.: btcpay.example.com
"
read SUBDOMAIN

echo "
Input the URL to be redirected to:
eg.: https://192.168.1.42:23001
"
read REDIRECT

sudo certbot certonly -a standalone -m $EMAIL --agree-tos \
-d $SUBDOMAIN --expand -n --pre-hook "service nginx stop" \
--post-hook "service nginx start" || exit 1

# copy in place on a remote machine if needed
#sudo cat /etc/letsencrypt/live/$SUBDOMAIN/fullchain.pem
#sudo cat /etc/letsencrypt/live/$SUBDOMAIN/privkey.pem

# add to /etc/nginx/sites-available/
cat EOF | sudo tee /etc/nginx/sites-available/${SUBDOMAIN}
# sudo cat /etc/nginx/sites-enabled/${SUBDOMAIN}
server {
  listen 80 http2;
  listen 443 ssl http2;
  server_name ${SUBDOMAIN};

  ssl_certificate /etc/letsencrypt/live/${SUBDOMAIN}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${SUBDOMAIN}/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate /etc/letsencrypt/live/${SUBDOMAIN}/chain.pem;

  location / {
    proxy_pass      ${REDIRECT};

    # For websockets
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;

    # from https://github.com/rootzoll/raspiblitz/blob/v1.9/home.admin/assets/nginx/snippets/ssl-proxy-params.conf
    proxy_redirect off;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    proxy_read_timeout 600;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
  }

  location /.well-known/lnurlp/openoms {
    add_header 'Access-Control-Allow-Origin' '*';

    proxy_pass      ${REDIRECT};

    proxy_redirect off;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    proxy_read_timeout 600;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
  }
}
EOF

# edit with
# sudo nano /etc/nginx/sites-available/$SUBDOMAIN

# add to /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/$SUBDOMAIN /etc/nginx/sites-enabled/

sudo nginx -t || exit 1

sudo systemctl restart nginx
