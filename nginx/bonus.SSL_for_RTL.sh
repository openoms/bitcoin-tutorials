# Script to install nginx and certbot to enable SSL connection for RTL
# To download, make executable and run:
# $ wget https://github.com/openoms/bitcoin-tutorials/raw/master/nginx/bonus.SSL_for_RTL.sh && sudo chmod +x bonus.SSL_for_RTL.sh && ./bonus.SSL_for_RTL.sh


# For the certificate to be obtained successfully a dynamic DNS and port forwarding is needed
# Need to forward port 80 to the IP of your RaspiBlitz for certbot
# Forward port 3002 to be able to access RTL from outside of your LAN

# https://www.raspberrypi.org/documentation/remote-access/web-server/nginx.md
echo ""
echo "***"
echo "installing Nginx"
echo "***"
echo ""

sudo apt-get install -y nginx
sudo /etc/init.d/nginx start

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
echo " you will be asked for and email address and your domain name - a dynamic DNS can be used"
echo " give a 4-11 character password and press [ENTER] to save default options for the certificate"
echo "***"
echo ""

wget https://dl.eff.org/certbot-auto
chmod +x certbot-auto
sudo ./certbot-auto --nginx

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
OnCalendar=*-*-* 16:00:00 

[Install]
WantedBy=timers.target
" | sudo tee -a /etc/systemd/system/certbot.timer

echo "
[Unit]
Description=Electrs
After=bitcoind.service

[Service]
WorkingDirectory=/home/admin/
ExecStart=/home/admin/certbot-auto renew

User=admin
Group=admin
Type=simple
KillMode=process
TimeoutSec=60
Restart=always
RestartSec=60
" | sudo tee -a /etc/systemd/system/certbot.service

sudo systemctl enable certbot.timer

echo ""
echo "***"
echo "Please type the domain/ddns you have generated the certificate for followed by [ENTER]"
read YOUR_DOMAIN

echo "Setting up nginx.conf"
echo ""
echo "If there is other an stream service is installed with Nginx already, you will need to edit the nginx.conf manually to remove the duplicate stream entry by running \`sudo nano /etc/nginx/nginx.conf\`."
echo "please press a key to continue"
read key

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
                ssl_session_cache shared:SSL:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_prefer_server_ciphers on;
        }
}
" | sudo tee -a /etc/nginx/nginx.conf

echo "allow port 3002 on ufw"
sudo ufw allow 3002

sudo systemctl enable nginx
sudo systemctl restart nginx

echo "If there is an error starting Nginx there is a stream service installed with Nginx already.  
You will need to edit the nginx.conf manually to remove the duplicate stream entry by running \`sudo nano /etc/nginx/nginx.conf\` \
and restart nginx with \`sudo systemctl restart nginx\`."
echo ""
echo "If successful connect to RTL through https on the port 3002"