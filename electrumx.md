# ElectrumX on a RaspiBlitz

This is a rough overview, the guide is work in progress.

Tested environments:
  * X86_64 Xeon E5 with 16GB RAM and SSD storage - estimated to sync in 5 days
  * bulding the database on a Raspberry Pi will likely take weeks

Issue: <https://github.com/rootzoll/raspiblitz/issues/1130>

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
# for thr RPi4 see the dependencies installed here:
# https://github.com/spesmilo/electrumx/blob/master/contrib/raspberrypi3/install_electrumx.sh

# places the binaries in /home/electrumx/.local/bin/
sudo -u electrumx pip3 install .

# alternative install method (places the binaries in /usr/local/bin):
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
* <https://electrumx-spesmilo.readthedocs.io/en/latest/environment.html>
* Can paste the this as a block to create the coinfig file, but fill in the PASSWORD_B (Bitcoin Core RPC password)
* the ports 50010 and 50011 are used to not interfere with a possible Electrs instance
* edit afterwards with `sudo nano /home/electrumx/.electrumx/electrumx.conf`
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
* <https://github.com/spesmilo/electrumx/blob/master/contrib/systemd/electrumx.service>
* Can paste the this as a block to create the electrumx.service file
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
* depending on the available RAM it is a good idea to keep at least 10GB swap:  
  <https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-debian-10>
  can consider ZRAM: 
  <https://haydenjames.io/raspberry-pi-performance-add-zram-kernel-parameters/>
  <https://github.com/rootzoll/raspiblitz/issues/2905>
```
sudo systemctl enable electrumx
sudo systemctl start electrumx
```

## Monitor
```
sudo journalctl -fu electrumx
sudo systemctl status electrumx
```

## Remove the electrumx user and installation (not the database)
```
sudo systemctl disable electrumx
sudo systemctl stop electrumx
sudo userdel -rf electrumx
# to remove the database directory:
# sudo rm -rf /mnt/hdd/app-storage/electrumx
```

## Set SSL  
* <https://electrumx-spesmilo.readthedocs.io/en/latest/HOWTO.html#creating-a-self-signed-ssl-certificate>


## Sources:
* <https://github.com/spesmilo/electrumx>
* <https://electrumx-spesmilo.readthedocs.io>
* <https://sparrowwallet.com/docs/server-performance.html>
* [Running an ElectrumX server on Ubuntu by @k3tan172](https://www.youtube.com/watch?v=QiX0rR_o_fI)