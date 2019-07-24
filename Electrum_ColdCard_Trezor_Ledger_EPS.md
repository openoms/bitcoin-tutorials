# Install Electrum with support for ColdCard, Trezor and Ledger connected to your own Electrum Personal Server

* make sure the system is up-to-date
```
sudo apt-get update
sudo apt-get upgrade
sudo apt install git-all
```
## download, verify, install Electrum

https://electrum.org/#download

* Download package:

    ` $ wget https://download.electrum.org/3.3.4/Electrum-3.3.4.tar.gz`

* Verify Electrum's downloaded source code

    At this stage, we are ready to verify Electrum's source code. The source code is signed by Thomas Voegtlin (https://electrum.org).   
    Let's import his public key:

    `$ gpg --keyserver pool.sks-keyservers.net --recv-keys 2BD5824B7F9470E6`
    ```
    gpg: key 2BD5824B7F9470E6: public key "Thomas Voegtlin (https://electrum.org) " imported
    gpg: no ultimately trusted keys found
    gpg: Total number processed: 1
    gpg:               imported: 1
    ```
* Confirm a correct key import and proceed to verify the downloaded file with the help of the signature file:

    `$ wget https://download.electrum.org/3.3.4/Electrum-3.3.4.tar.gz.asc`

        `$ gpg --verify Electrum-3.3.4.tar.gz.asc`
    ```
    gpg: Signature made Tue 12 Dec 2017 17:06:09 AEDT
    gpg:                using RSA key 2BD5824B7F9470E6
    gpg: Good signature from "Thomas Voegtlin (https://electrum.org) " [unknown]
    gpg:                 aka "ThomasV " [unknown]
    gpg:                 aka "Thomas Voegtlin " [unknown]
    gpg: WARNING: This key is not certified with a trusted signature!
    gpg:          There is no indication that the signature belongs to the owner.
    Primary key fingerprint: 6694 D8DE 7BE8 EE56 31BE  D950 2BD5 824B 7F94 70E6
    ```

* Note gpg: Good signature on Line 3. All seems to be in order!
* Install Electrum

    To install Electrum bitcoin wallet, we first need to preform an installation of all prerequisites:

    Install dependencies: 	


    `sudo apt-get install python3-setuptools python3-pyqt5 python3-pip`

    Install Electrum using the command:

    `python3 -m pip install --user Electrum-3.3.4.tar.gz[fast]`

    `cd Electrum-3.3.4`

    ## (optional) zbar to read QR codes with the camera
    `sudo apt-get install zbar-tools`

    ## (optional) install and activate a virtual environment 
    `apt-get install python3-venv`

    `python3 -m venv venv`

    `source venv/bin/activate`

---

## ColdCard for Electrum
```
sudo apt-get install python-dev libusb-1.0-0-dev libudev-dev
sudo pip install --upgrade setuptools
sudo pip install hidapi pyqt5 "ckcc-protocol[cli]"
```
add the udev rules
```
cd /etc/udev/rules.d/
sudo wget https://raw.githubusercontent.com/Coldcard/ckcc-protocol/master/51-coinkite.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

## Trezor for Electrum
```
sudo apt-get install python3-dev python3-pip cython3 libusb-1.0-0-dev libudev-dev
sudo pip3 install --upgrade setuptools
pip3 install trezor
sudo pip3 install trezor[hidapi]
```
Add the udev rules:
```
cd /etc/udev/rules.d   
sudo wget https://raw.githubusercontent.com/trezor/trezor-common/master/udev/51-trezor.rules`

sudo cp udev/*.rules /etc/udev/rules.d/  
sudo udevadm trigger  
sudo udevadm control --  reload-rules  
sudo groupadd plugdev 
sudo usermod -aG plugdev `whoami`
```

## Ledger for Electrum
```
apt-get install libudev-dev libusb-1.0-0-dev
ln -s /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so
sudo pip3 install btchip-python
wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash
```
https://support.ledger.com/hc/en-us/articles/115005165269-What-if-Ledger-Wallet-is-not-recognized-on-Linux-

## Documentation on how to add udev rules in Linux:

https://github.com/bitcoin-core/HWI/tree/master/udev  
https://github.com/spesmilo/electrum-docs/blob/master/hardware-linux.rst 

---

## Electrum Personal Server

Follow Stadicus`s guide: 
https://github.com/Stadicus/RaspiBolt/blob/master/raspibolt_64_electrum.md

some permissions I needed to fix:

>ssh admin@Raspibolt

>sudo su - bitcoin

>ls -la

`drwx------ 6 bitcoin bitcoin 4096 Jan  2 23:55 .local`

>chmod 755 .local

`drwxr-xr-x 6 bitcoin bitcoin 4096 Jan  2 23:55 .local`

monitor the log:
>tail -f /tmp/electrumpersonalserver.log

restrict Electrum to use your own EPS, point it to the LAN IP of your Raspibolt
>python3 run_electrum --oneserver --server [RaspiBolt.IP]:50002:s
