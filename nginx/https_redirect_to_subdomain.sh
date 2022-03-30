#!/bin/bash

echo "
Input your email:
"
read EMAIL

echo "
Input a subdomain set up with an A record pointing to this server:
eg.: tips.diynodes.com
"
read SUBDOMAIN

echo "
Input the URL where the subdomain should be redirected to:
eg.: https://pay.diynodes.com/apps/otJAn2YiMRKeHnKrsZYQF8VuCJD/pos
"
read SERVER

echo "
Input the host address where the site is served:
eg.: https://192.168.1.42:23001
"
read SERVER

sudo certbot certonly -a standalone -m $EMAIL --agree-tos \
-d $SUBDOMAIN --expand -n --pre-hook "service nginx stop" \
--post-hook "service nginx start" || exit 1


echo "\
server {
  listen 443 ssl;
  server_name SUBDOMAIN;
  return 301  $REDIRECT;
  ssl on;

  ssl_certificate /etc/letsencrypt/live/tips.diynodes.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/tips.diynodes.com/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate /etc/letsencrypt/live/tips.diynodes.com/chain.pem;

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass $SERVER;
  }
}
" | sudo tee /etc/nginx/sites-available/$SUBDOMAIN

# edit with
# sudo nano /etc/nginx/sites-available/$SUBDOMAIN

# add to /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/$SUBDOMAIN /etc/nginx/sites-enabled/

sudo nginx -t || exit 1

sudo systemctl restart nginx
