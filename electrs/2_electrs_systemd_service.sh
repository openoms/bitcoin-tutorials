# Install the electrs systemd service.
# Prerequisite: 1_electrs_on_RaspiBlitz.sh

# To download and run:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/2_electrs_systemd_service.sh && bash 2_electrs_systemd_service.sh

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
ExecStart=/home/admin/electrs/target/release/electrs --index-batch-size=10 --jsonrpc-import --db-dir /mnt/hdd/electrs/db  --electrum-rpc-addr="0.0.0.0:50001" --cookie="raspibolt:$PASSWORD_B"

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