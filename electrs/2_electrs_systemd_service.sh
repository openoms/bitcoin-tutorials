# Install the electrs systemd service.
# Prerequisite: 1_electrs_on_RaspiBlitz.sh

# To download and run:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/2_electrs_systemd_service.sh && bash 2_electrs_systemd_service.sh

sudo systemctl stop electrs
sudo systemctl disable electrs
sudo rm /etc/systemd/system/electrs.service

# sudo nano /etc/systemd/system/electrs.service 
echo "
[Unit]
Description=Electrs
After=bitcoind.service

[Service]
WorkingDirectory=/home/electrs/electrs
ExecStart=/home/electrs/electrs/target/release/electrs --index-batch-size=10 --electrum-rpc-addr="0.0.0.0:50001"
User=electrs
Group=electrs
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