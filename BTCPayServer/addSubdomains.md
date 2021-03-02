# Add subdomains and redirects to BTCPayServer

In this example configuration I am using a main domain for BTCpayserver and two apps to redirect the subdomains to.

All subdomains need an A record pointing to the same IP address where BTCPayServer is exposed.

```
echo "Input your email:"
read EMAIL

echo "Input 3 subdomains separated with commas (eg: pay.example.com,tips.example.com,status.example.com)"
read SUBDOMAINS

echo "Input the the URL to be redirected to for the second domain"
read REDIRECT1
echo "Input the the URL to be redirected to for the third domain"
read REDIRECT2

certbot certonly -a standalone -m $EMAIL --agree-tos \
-d $SUBDOMAINS --expand -n --pre-hook "service nginx stop" \
--post-hook "service nginx start" || exit 1

firstDomain=$(echo $SUBDOMAINS|cut -d"," -f1)

# copy in place if needed
#cat /etc/letsencrypt/live/$firstDomain/fullchain.pem 
#cat /etc/letsencrypt/live/$firstDomain/privkey.pem 

# Add to /etc/nginx/sites-available/btcpayserver
echo "
server {
  listen 443 ssl;
  server_name $(echo $SUBDOMAINS|cut -d"," -f2);
  return 301 $REDIRECT1;
  ssl on;

  ssl_certificate /etc/letsencrypt/live/$firstDomain/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$firstDomain/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate /etc/letsencrypt/live/$firstDomain/chain.pem;

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://localhost:23000;
  }
}

server {
  listen 443 ssl;
  server_name $(echo $SUBDOMAINS|cut -d"," -f3);
  return 301 $REDIRECT2;
  ssl on;

  ssl_certificate /etc/letsencrypt/live/$firstDomain/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$firstDomain/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_protocols TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_trusted_certificate /etc/letsencrypt/live/$firstDomain/chain.pem;

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://localhost:23000;
  }
} " | sudo tee -a /etc/nginx/sites-available/btcpayserver
```