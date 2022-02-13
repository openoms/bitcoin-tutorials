#!/bin/bash

echo "
Input your email:
"
read EMAIL

echo "
Input a subdomain set up with an A record pointing to this server:
eg.: mempool.example.com
"
read SUBDOMAIN

echo "
Input the URL to be redirected to:
eg.: https://192.168.1.42:4081
"
read REDIRECT

sudo certbot certonly -a standalone -m $EMAIL --agree-tos \
-d $SUBDOMAIN --expand -n --pre-hook "service nginx stop" \
--post-hook "service nginx start" || exit 1

# copy in place if needed
#sudo cat /etc/letsencrypt/live/$SUBDOMAIN/fullchain.pem 
#sudo cat /etc/letsencrypt/live/$SUBDOMAIN/privkey.pem 

# Add to /etc/nginx/sites-available/btcpayserver
echo "\
server {
  listen 443 ssl;
  server_name $SUBDOMAIN;

  ssl_certificate /etc/letsencrypt/live/$SUBDOMAIN/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$SUBDOMAIN/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate /etc/letsencrypt/live/$SUBDOMAIN/chain.pem;

  location / {
          proxy_pass      $REDIRECT;
  }
}" | sudo tee /etc/nginx/sites-available/$SUBDOMAIN

# edit with
# sudo nano /etc/nginx/sites-available/$SUBDOMAIN

sudo ln -s /etc/nginx/sites-available/$SUBDOMAIN /etc/nginx/sites-enabled/

sudo nginx -t || exit 1

sudo systemctl reload nginx
