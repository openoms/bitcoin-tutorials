# ElectrumX on a RaspiBlitz

This is a rought overview, the guide is work in progress.

Tested environments:
  * X86_64 Xeon E5 with 16GB RAM and SSD storage
  * bulding the database on a Raspberry Pi will likely take weeks

## Prepare the system and directories
```
# create a dedicated user
sudo adduser --disabled-password --gecos "" electrumx
cd /home/electrumx

sudo -u electrumx git clone https://github.com/spesmilo/electrumx.git
cd electrumx

# installation
# dependencies
sudo -u electrumx pip install aiohttp pylru
sudo -u electrumx pip3 install .
# sudo -u electrumx python3 setup.py build
# sudo python3 setup.py install

# create the database directory in /mnt/hdd/app-storage (on the disk)
sudo mkdir -p /mnt/hdd/app-storage/electrumx/db
sudo chown -R electrumx:electrumx /mnt/hdd/app-storage/electrumx

# create a symlink to /home/electrumx/.electrumx
sudo ln -s /mnt/hdd/app-storage/electrumx /home/electrumx/.electrumx
sudo chown -R electrumx:electrumx /home/electrumx/.electrumx

```

## Create a config file  
https://electrumx-spesmilo.readthedocs.io/en/latest/environment.html
Can paste the thsi as a block, but fill in the PASSWORD_B (Bitcoin Core RPC password)
```
echo "\
DB_DIRECTORY=/home/electrumx/.electrumx/db
DAEMON_URL=http://raspibolt:PASSWORD_B@127.0.0.1
COIN=Bitcoin

SERVICES = tcp://:50010,ssl://:50011,rpc://
PEER_DISCOVERY = off
COST_SOFT_LIMIT = 0
COST_HARD_LIMIT = 0

NET=mainnet
CACHE_MB=1200

SSL_CERTFILE=/home/electrumx/.electrumx/certfile.crt
SSL_KEYFILE=/home/electrumx/.electrumx/keyfile.key
BANNER_FILE=/home/electrumx/.electrumx/banner
DONATION_ADDRESS=your-donation-address
" | sudo -u electrumx tee /home/electrumx/.electrumx/electrumx.conf
```

## Create a systemd service  
https://github.com/spesmilo/electrumx/blob/master/contrib/systemd/electrumx.service
```
echo "\
[Unit]
Description=Electrumx
After=network.target

[Service]
EnvironmentFile=/home/electrumx/.electrumx/electrumx.conf
ExecStart=/home/electrumx/.local/bin/electrumx_server
User=electrumx
LimitNOFILE=8192
TimeoutStopSec=30min

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/electrumx.service
```

## Start
```
sudo systemctl enable electrumx
sudo systemctl start electrumx
```

## Monitor
```
sudo journalctl -fu electrumx
sudo systemctl status electrumx
```

## Remove user and installation (not the database)
```
sudo systemctl disable electrumx
sudo systemctl stop electrumx
sudo userdel -rf electrumx
# to remove the database directory:
# sudo rm -rf /mnt/hdd/app-storage/electrumx
```

## Set SSL  
https://electrumx-spesmilo.readthedocs.io/en/latest/HOWTO.html#creating-a-self-signed-ssl-certificate


## Sources:
https://github.com/spesmilo/electrumx
https://electrumx-spesmilo.readthedocs.io/en/latest/index.html
https://sparrowwallet.com/docs/server-performance.html