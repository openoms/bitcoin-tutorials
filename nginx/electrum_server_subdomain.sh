#!/bin/bash

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
eg.: electrum.example.com
"
read SUBDOMAIN

echo "
Input the TCP port of the Electrum Server to be redirected to:
eg.: 192.168.1.42:50002
"
read REDIRECT


sudo certbot certonly -a standalone -m $EMAIL --agree-tos \
-d $SUBDOMAIN --expand -n --pre-hook "service nginx stop" \
--post-hook "service nginx start" || exit 1


# Setting up the nginx.conf
    isConfigured=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'upstream electrum')
    if [ ${isConfigured} -gt 0 ]; then
            echo "electrum is already configured with Nginx. To edit manually run \`sudo nano /etc/nginx/nginx.conf\`"

    elif [ ${isConfigured} -eq 0 ]; then

            isStream=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'stream {')
            if [ ${isStream} -eq 0 ]; then

            echo "\
stream {
        upstream electrum {
                server $REDIRECT;
        }
        server {
                listen 50002 ssl;
                proxy_pass electrum;
                ssl_certificate /etc/letsencrypt/live/$SUBDOMAIN/fullchain.pem;
                ssl_certificate_key /etc/letsencrypt/live/$SUBDOMAIN/privkey.pem ;
                ssl_session_cache shared:SSL-electrum:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

            elif [ ${isStream} -eq 1 ]; then
                    sudo truncate -s-2 /etc/nginx/nginx.conf
                    echo "\
        upstream electrum {
                server $REDIRECT;
        }
        server {
                listen 50022 ssl;
                proxy_pass electrum;
                ssl_certificate /etc/letsencrypt/live/$SUBDOMAIN/fullchain.pem;
                ssl_certificate_key /etc/letsencrypt/live/$SUBDOMAIN/privkey.pem;
                ssl_session_cache shared:SSL-electrum:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

            elif [ ${isStream} -gt 1 ]; then
                    echo " Too many 'stream' commands in nginx.conf. Please edit manually: \`sudo nano /etc/nginx/nginx.conf\` and retry"
                    exit 1
            fi
    fi

# test nginx
sudo nginx -t || exit 1

# restart
sudo systemctl restart nginx
