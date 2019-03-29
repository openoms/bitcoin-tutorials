# A script to set up the Electrum Server in Rust on the RaspiBlitz to be used with Eclair
# Sets up the automatic start of electrs and nginx and certbot

# To download this script, make executable and run:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrs_automation_for_Eclair.sh && sudo chmod +x electrs_automation_for_Eclair.sh && ./electrs_automation_for_Eclair.sh

# For the certificate to be obtained successfully a dynamic DNS and port forwarding is needed
# Need to forward port 80 to the IP of your RaspiBlitz for certbot
# Forward port 50002 to be able to access you electrs from outside of your LAN

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
echo "To confirm that the port 80 is forwarded to the IP of the RaspiBlitz press [ENTER]" 
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

echo "setting up nginx.confsu"
echo "***"
echo ""
# sudo nano /etc/nginx/nginx.conf
echo "
stream {
        upstream electrs {
                server 127.0.0.1:50001;
        }

        server {
                listen 50002 ssl;
                proxy_pass electrs;

                ssl_certificate /etc/letsencrypt/live/$YOUR_DOMAIN/fullchain.pem;
                ssl_certificate_key /etc/letsencrypt/live/$YOUR_DOMAIN/privkey.pem;
                ssl_session_cache shared:SSL:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_prefer_server_ciphers on;
        }
}
" | sudo tee -a /etc/nginx/nginx.conf

sudo systemctl enable nginx
sudo systemctl start nginx

echo ""
echo "***"
echo "Type the PASSWORD B of your RaspiBlitz followed by [ENTER] for the electrs service:"
read PASSWORD_B

# sudo nano /etc/systemd/system/electrs.service 
echo "
[Unit]
Description=Electrs
After=bitcoind.service

[Service]
WorkingDirectory=/home/admin/electrs
ExecStart=/home/admin/electrs/target/release/electrs --release -- -vvvv --index-batch-size=10 --jsonrpc-import --db-dir /mnt/hdd/electrs/db  --electrum-rpc-addr="0.0.0.0:50001" --cookie="raspibolt:$PASSWORD_B"

User=admin
Group=admin
Type=simple
KillMode=process
TimeoutSec=60
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
" | sudo tee -a /etc/systemd/system/electrs.service 

sudo systemctl enable electrs
sudo systemctl start electrs

echo "allow port 50002 on ufw"
sudo ufw allow 50002

echo "Set the \`Current Electrum server\` of you Eclair wallet to \`$YOUR_DOMAIN:50002\` and make sure the port 5002 is forwarded on your router"