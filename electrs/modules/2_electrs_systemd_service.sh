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
ExecStart=/home/electrs/electrs/target/release/electrs --index-batch-size=10 --electrum-rpc-addr=\"0.0.0.0:50001\"
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

# Hidden Service for electrs if Tor active

source /mnt/hdd/raspiblitz.conf

if [ "${runBehindTor}" = "on" ]; then
    isElectrsTor=$(sudo cat /etc/tor/torrc 2>/dev/null | grep -c 'electrs')
    if [ ${isElectrsTor} -eq 0 ]; then
        echo "
        # Hidden Service for Electrum Server
        HiddenServiceDir /mnt/hdd/tor/electrs
        HiddenServiceVersion 3
        HiddenServicePort 50001 127.0.0.1:50001
        " | sudo tee -a /etc/tor/torrc

        sudo systemctl restart tor
        sudo systemctl restart tor@default
    fi
    TOR_ADDRESS=$(sudo cat /mnt/hdd/tor/electrs/hostname)
    echo ""
    echo "***"
    echo "The hidden service address for electrs is:"
    echo "$TOR_ADDRESS"
    echo "***"
    echo "" 
fi