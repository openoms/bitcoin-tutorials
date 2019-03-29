

sudo systemctl stop nginx
sudo systemctl disable nginx
sudo apt remove -y nginx

sudo sytemctl stop certbot
sudo sytemctl disable certbot
sudo rm /etc/systemd/system/certbot.service
sudo rm certbot*

sudo nano systemctl stop electrs
sudo nano systemctl disable electrs