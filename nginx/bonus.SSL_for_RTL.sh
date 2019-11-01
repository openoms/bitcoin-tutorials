# Script to install nginx and certbot to enable SSL connection for RTL
# To download and run:
# $ wget https://github.com/openoms/bitcoin-tutorials/raw/master/nginx/bonus.SSL_for_RTL.sh && bash bonus.SSL_for_RTL.sh


# For the certificate to be obtained successfully a dynamic DNS and port forwarding is needed
# Need to forward port 80 to the IP of your RaspiBlitz for certbot
# Forward port 3002 to be able to access RTL from outside of your LAN

# https://www.raspberrypi.org/documentation/remote-access/web-server/nginx.md

echo ""
echo "***"
echo "Please confirm that the port 80 is forwarded to the IP of the RaspiBlitz by pressing [ENTER]" 
read key

echo ""
echo "***"
echo "Please type the domain/ddns you have generated the certificate for followed by [ENTER]"
read YOUR_DOMAIN

echo ""
echo "***"
echo "Type an email address that will be used to register the SSL certificate and press [ENTER]"
read YOUR_EMAIL

echo "installing Nginx and certbot"
sudo apt-get install -y nginx-full certbot
sudo /etc/init.d/nginx start

echo "allow port 80 on ufw"
sudo ufw allow 80

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


echo "Setting up nginx.conf"
echo "***"
echo ""

isRTL=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'upstream RTL')
if [ ${isRTL} -gt 0 ]; then
        echo "RTL is already configured with Nginx. To edit manually run \`sudo nano /etc/nginx/nginx.conf\`"

elif [ ${isRTL} -eq 0 ]; then

        isStream=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'stream {')
        if [ ${isStream} -eq 0 ]; then

        echo "
stream {
        upstream RTL {
                server 127.0.0.1:3000;
        }
        server {
                listen 3002 ssl;
                proxy_pass RTL;
                ssl_certificate /etc/letsencrypt/live/$YOUR_DOMAIN/fullchain.pem;
                ssl_certificate_key /etc/letsencrypt/live/$YOUR_DOMAIN/privkey.pem;
                ssl_session_cache shared:SSL-RTL:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

        elif [ ${isStream} -eq 1 ]; then
                sudo truncate -s-2 /etc/nginx/nginx.conf
                echo "

        upstream RTL {
                server 127.0.0.1:3000;
        }
        server {
                listen 3002 ssl;
                proxy_pass RTL;
                ssl_certificate /etc/letsencrypt/live/$YOUR_DOMAIN/fullchain.pem;
                ssl_certificate_key /etc/letsencrypt/live/$YOUR_DOMAIN/privkey.pem;
                ssl_session_cache shared:SSL:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

        elif [ ${isStream} -gt 1 ]; then

                echo " Too many \`stream\` commands in nginx.conf. Please edit manually: \`sudo nano /etc/nginx/nginx.conf\` and retry"
                exit 1
        fi
fi

echo "allow port 3002 on ufw"
sudo ufw allow 3002

sudo systemctl enable nginx
sudo systemctl restart nginx

echo ""
echo "Connect to RTL through https on the port 3002 and forward the port on your router to access outside of the LAN"
