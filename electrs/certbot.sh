# For the certificate to be obtained successfully a dynamic DNS and port forwarding is needed
# Need to forward port 80 to the IP of your RaspiBlitz for certbot
# Forward port 50002 to be able to access you electrs from outside of your LAN

# https://www.raspberrypi.org/documentation/remote-access/web-server/nginx.md

echo ""
echo "***"
echo "Please type the domain/dynamicDNS you want to use for Electrs and press [ENTER]"
read YOUR_DOMAIN

echo ""
echo "***"
echo "Please type an email that will be used to register the SSL certificate and press [ENTER]"
read YOUR_EMAIL

echo ""
echo "***"
echo "Please confirm that the port 80 is forwarded to the IP of the RaspiBlitz by pressing [ENTER]" 
read key

echo "allow port 80 on ufw"
sudo ufw allow 80

# https://certbot.eff.org/lets-encrypt/debianother-nginx
echo ""
echo "***"
echo "Installing certbot"
echo "Will ask for an email address and a domain name - a dynamic DNS can be used"
echo "Use the default settings in the other options"
echo "***"
echo ""

#wget https://dl.eff.org/certbot-auto
#chmod +x certbot-auto
#sudo ./certbot-auto --nginx

sudo apt install -y certbot
# get SSL cert
sudo certbot certonly -a standalone -m $YOUR_EMAIL --agree-tos -d $YOUR_DOMAIN --pre-hook "service nginx stop" --post-hook "service nginx start"


# Your certificate and chain have been saved at:
# /etc/letsencrypt/live/$YOUR_DOMAIN/fullchain.pem
# Your key file has been saved at:
# /etc/letsencrypt/live/$YOUR_DOMAIN/privkey.pem

echo ""
echo "***"
echo "Setting up certbot-auto renewal service"
echo "***"
echo ""

echo "
[Unit]
Description=Certbot-auto renewal service

[Timer]
OnBootSec=20min
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
" | sudo tee -a /etc/systemd/system/certbot.timer

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