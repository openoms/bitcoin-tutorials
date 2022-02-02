# Fulcrum on a RaspiBlitz

This is a rough overview, the guide is work in progress.

Tested environments:
  * Raspberry Pi4 8GB 64bit RaspberryOS with SSD and ZRAM

Issue: <https://github.com/rootzoll/raspiblitz/issues/2924>

## Prepare bitcoind
* To avoid errors like
    ```
    503 (content): Work queue depth exceeded 
    ``` 
    set in the `/mnt/hdd/bitcoin/bitcoin.conf`:
    ```
    txindex=1
    whitelist=download@127.0.0.1
    rpcworkqueue=512
    rpcthreads=128
    ```
   `zmqpubhashblock=tcp://0.0.0.0:8433` is not set for now

* restart bitcoind
    ```
    sudo systemctl bitcoind restart
    ```
    if the txindex was not built before wait until finishes (monitor the bitcoin `debug.log`).

## Prepare the system and directories

```
# create a dedicated user
sudo adduser --disabled-password --gecos "" fulcrum
cd /home/fulcrum

# sudo -u fulcrum git clone https://github.com/cculianu/Fulcrum
# cd fulcrum

# dependencies
# sudo apt install -y libzmq3-dev

# set the platform
if [ $(uname -m) = "aarch64" ]; then
  build="arm64-linux"
elif [ $(uname -m) = "x86_64" ]; then
  build="x86_64-linux-ub16"
fi

# download the prebuilt binary
sudo -u fulcrum wget https://github.com/cculianu/Fulcrum/releases/download/v1.6.0/Fulcrum-1.6.0-${build}.tar.gz
sudo -u fulcrum  wget https://github.com/cculianu/Fulcrum/releases/download/v1.6.0/Fulcrum-1.6.0-${build}.tar.gz.asc
sudo -u fulcrum  wget https://github.com/cculianu/Fulcrum/releases/download/v1.6.0/Fulcrum-1.6.0-${build}.tar.gz.sha256sum

# Verify
# get the PGP key
curl https://raw.githubusercontent.com/Electron-Cash/keys-n-hashes/master/pubkeys/calinkey.txt | sudo -u fulcrum gpg --import

# look for 'Good signature'
sudo -u fulcrum  gpg --verify Fulcrum-1.6.0-${build}.tar.gz.asc

# look for 'OK'
sudo -u fulcrum sha256sum -c Fulcrum-1.6.0-${build}.tar.gz.sha256sum

# decompress
sudo -u fulcrum tar -xvf Fulcrum-1.6.0-${build}.tar.gz

# create the database directory in /mnt/hdd/app-storage (on the disk)
sudo mkdir -p /mnt/hdd/app-storage/fulcrum/db
sudo chown -R fulcrum:fulcrum /mnt/hdd/app-storage/fulcrum

# create a symlink to /home/fulcrum/.fulcrum
sudo ln -s /mnt/hdd/app-storage/fulcrum /home/fulcrum/.fulcrum
sudo chown -R fulcrum:fulcrum /home/fulcrum/.fulcrum

```

## Create a config file  
* <https://github.com/cculianu/Fulcrum/blob/master/doc/fulcrum-example-config.conf>
* Can paste the this as a block to create the config file, but fill in the PASSWORD_B (Bitcoin Core RPC password):
```
PASSWORD_B="your-password-here"
```
```
echo "\
datadir = /home/fulcrum/.fulcrum/db
bitcoind = 127.0.0.1:8332
rpcuser = raspibolt
rpcpassword = ${PASSWORD_B}
tcp = 0.0.0.0:50020

#cert = /path/to/server-cert.pem
#key = /path/to/server-key.pem

# fast-sync failed on the RPi so keep it off
# fast-sync = 4000
" | sudo -u fulcrum tee /home/fulcrum/.fulcrum/fulcrum.conf
```
* the ports 50020 and 50011 are used to not interfere with a possible Electrs or ElectrumX instance
* edit afterwards with `sudo nano /home/fulcrum/.fulcrum/fulcrum.conf`

## Create a systemd service  
* <https://github.com/spesmilo/fulcrum/blob/master/contrib/systemd/fulcrum.service>
* Can paste this as a block to create the fulcrum.service file:
```
echo "\
[Unit]
Description=Fulcrum
After=network.target bitcoind.service

[Service]
ExecStart=/home/fulcrum//Fulcrum-1.6.0-${build}/Fulcrum /home/fulcrum/.fulcrum/fulcrum.conf
User=fulcrum
LimitNOFILE=8192
TimeoutStopSec=30min
Restart=on-failure

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/fulcrum.service
```

## Start
* depending on the available RAM it is a good idea to keep at least 10GB swap:  
  <https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-debian-10>
  can consider ZRAM: 
  <https://haydenjames.io/raspberry-pi-performance-add-zram-kernel-parameters/>
  <https://github.com/rootzoll/raspiblitz/issues/2905>
```
sudo systemctl enable fulcrum
sudo systemctl start fulcrum
```

## Monitor
```
sudo journalctl -fu fulcrum
sudo systemctl status fulcrum
```

## Remove the fulcrum user and installation (not the database)
```
sudo systemctl disable fulcrum
sudo systemctl stop fulcrum
sudo userdel -rf fulcrum
# to remove the database directory:
# sudo rm -rf /mnt/hdd/app-storage/fulcrum
```

## Sources:
* <https://github.com/cculianu/Fulcrum>
* <https://sparrowwallet.com/docs/server-performance.html>
