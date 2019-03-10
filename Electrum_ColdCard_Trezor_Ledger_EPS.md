# Install Electrum with support for ColdCard, Trezor and Ledger connected to your own Electrum Personal Server


>sudo apt-get update

>sudo apt-get upgrade

>sudo apt install git-all

## download, verify, install Electrum
>wget https://download.electrum.org/3.3.2/Electrum-3.3.2.tar.gz https://download.electrum.org/3.3.2/Electrum-3.3.2.tar.gz.asc

Verify Electrum's downloaded source code
At this stage, we are ready to verify Electrum's source code. The source code is signed by Thomas Voegtlin (https://electrum.org).   
Let's import his public key:

> gpg --keyserver pool.sks-keyservers.net --recv-keys 2BD5824B7F9470E6
```
gpg: key 2BD5824B7F9470E6: public key "Thomas Voegtlin (https://electrum.org) " imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 1
gpg:               imported: 1
```
Confirm a correct key import and proceed to verify the downloaded file with with the help of the signature file:

> gpg --verify Electrum-3.3.2.tar.gz.asc Electrum-3.3.2.tar.gz
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

Note gpg: Good signature on Line 3. All seems to be in order!
Install Electrum
To install Electrum bitcoin wallet, we first need to preform an installation of all prerequisites:

> sudo apt-get install python3-setuptools python3-pyqt5 python3-pip

Install Electrum using the command:

>sudo pip3 install Electrum-3.3.2.tar.gz

>cd Electrum-3.3.2

## install zbar to read QR codes with the camera
>sudo apt-get install zbar-tools

## (optional) install and activate a virtual environment 
>apt-get install python3-venv

>python3 -m venv venv

>source venv/bin/activate

---

## to install ColdCard for Electrum
>sudo apt-get install python-dev libusb-1.0-0-dev libudev-dev

>sudo pip install --upgrade setuptools

>sudo pip install hidapi

>pip install pyqt5 

>pip install "ckcc-protocol[cli]"

add udev rules:
> cd /etc/udev/rules.d/

>sudo wget https://raw.githubusercontent.com/Coldcard/ckcc-protocol/master/51-coinkite.rules

>sudo udevadm control --reload-rules && sudo udevadm trigger

## install Trezor for Electrum
>sudo apt-get install python3-dev python3-pip cython3 libusb-1.0-0-dev libudev-dev

>pip3 install --upgrade setuptools

>pip3 install trezor

>sudo pip3 install trezor[hidapi]

## install Ledger for Electrum

>apt-get install libudev-dev

>apt-get install libusb-1.0-0-dev

>ln -s /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so

>sudo pip3 install btchip-python

>wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash
<https://support.ledger.com/hc/en-us/articles/115005165269-What-if-Ledger-Wallet-is-not-recognized-on-Linux->

### Documentation on how to add udev rules in linux:
https://github.com/spesmilo/electrum-docs/blob/master/hardware-linux.rst 

---

## install Electrum Personal server
https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_64_electrum.md  

some debugging which worked for me:

>ssh admin@Raspibolt

>sudo su - bitcoin

>ls -la

`drwx------ 6 bitcoin bitcoin 4096 Jan  2 23:55 .local`

>chmod 755 .local

`drwxr-xr-x 6 bitcoin bitcoin 4096 Jan  2 23:55 .local`

>sudo ufw status

allow your chosen port in ufw (default is 50002)

>sudo ufw allow 50002

>sudo systemctl start eps.service

monitor the log:
>tail -f /tmp/electrumpersonalserver.log

restrict Electrum to use your own EPS, point it to the LAN IP of your Raspibolt
>python3 run_electrum --oneserver --server 192.168.?.???:50002:s

