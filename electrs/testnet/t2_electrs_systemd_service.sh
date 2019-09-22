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
WorkingDirectory=/home/admin/electrs
ExecStart=/home/admin/electrs/target/release/electrs --index-batch-size=10 --jsonrpc_import --db-dir /mnt/hdd/electrs/testnetdb  --electrum-rpc-addr=\"0.0.0.0:60001\" --network testnet --timestamp -vvvv

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